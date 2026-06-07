"""Unit tests for the NGO service Flask application."""

import json
import os
import sys
from unittest.mock import MagicMock, patch

import pytest

# Prevent the real module from connecting to PostgreSQL on import.
os.environ.setdefault("DATABASE_URL", "postgres://test:test@localhost:5432/testdb")


@pytest.fixture()
def client():
    """Create a Flask test client with all DB interactions mocked."""
    mock_pool = MagicMock()

    with patch("psycopg2.pool.SimpleConnectionPool", return_value=mock_pool):
        # Remove cached module so it re-imports with the mock active.
        sys.modules.pop("app", None)
        import app as ngo_app

        ngo_app.app.config["TESTING"] = True
        ngo_app.pool = mock_pool
        with ngo_app.app.test_client() as c:
            yield c, mock_pool


# ── /health ──────────────────────────────────────────────────────────


class TestHealthEndpoint:
    def test_health_returns_ok(self, client):
        c, _ = client
        resp = c.get("/health")
        assert resp.status_code == 200
        data = resp.get_json()
        assert data["status"] == "ok"
        assert data["service"] == "ngo-service"


# ── POST /ngos ───────────────────────────────────────────────────────


class TestCreateNgo:
    def _mock_cursor(self, pool, returning):
        """Wire up pool → conn → cursor to return *returning* from fetchone."""
        conn = MagicMock()
        cursor = MagicMock()
        cursor.fetchone.return_value = returning
        cursor.__enter__ = MagicMock(return_value=cursor)
        cursor.__exit__ = MagicMock(return_value=False)
        conn.cursor.return_value = cursor
        pool.getconn.return_value = conn
        return conn, cursor

    def test_create_ngo_success(self, client):
        c, pool = client
        row = {"id": 1, "name": "ONG A", "email": "a@a.com", "cause": "edu", "city": "SP"}
        conn, cur = self._mock_cursor(pool, row)

        resp = c.post(
            "/ngos",
            data=json.dumps({"name": "ONG A", "email": "a@a.com", "cause": "edu", "city": "SP"}),
            content_type="application/json",
        )
        assert resp.status_code == 201
        assert resp.get_json()["name"] == "ONG A"
        conn.commit.assert_called_once()
        pool.putconn.assert_called_once_with(conn)

    def test_create_ngo_missing_fields(self, client):
        c, _ = client
        resp = c.post(
            "/ngos",
            data=json.dumps({"name": "ONG A"}),
            content_type="application/json",
        )
        assert resp.status_code == 400
        assert "obrigat" in resp.get_json()["error"].lower()

    def test_create_ngo_empty_body(self, client):
        c, _ = client
        resp = c.post("/ngos", content_type="application/json")
        assert resp.status_code == 400

    def test_create_ngo_duplicate_email(self, client):
        """IntegrityError should return 409."""
        import psycopg2

        c, pool = client
        conn = MagicMock()
        cursor = MagicMock()
        cursor.execute.side_effect = psycopg2.IntegrityError("duplicate key")
        cursor.__enter__ = MagicMock(return_value=cursor)
        cursor.__exit__ = MagicMock(return_value=False)
        conn.cursor.return_value = cursor
        pool.getconn.return_value = conn

        resp = c.post(
            "/ngos",
            data=json.dumps({"name": "X", "email": "dup@x.com", "cause": "y", "city": "z"}),
            content_type="application/json",
        )
        assert resp.status_code == 409
        conn.rollback.assert_called_once()
        pool.putconn.assert_called_once_with(conn)

    def test_create_ngo_internal_error(self, client):
        """Generic exception should return 500."""
        c, pool = client
        conn = MagicMock()
        cursor = MagicMock()
        cursor.execute.side_effect = RuntimeError("boom")
        cursor.__enter__ = MagicMock(return_value=cursor)
        cursor.__exit__ = MagicMock(return_value=False)
        conn.cursor.return_value = cursor
        pool.getconn.return_value = conn

        resp = c.post(
            "/ngos",
            data=json.dumps({"name": "X", "email": "e@x.com", "cause": "y", "city": "z"}),
            content_type="application/json",
        )
        assert resp.status_code == 500
        conn.rollback.assert_called_once()
        pool.putconn.assert_called_once_with(conn)


# ── GET /ngos ────────────────────────────────────────────────────────


class TestGetNgos:
    def test_get_ngos_success(self, client):
        c, pool = client
        conn = MagicMock()
        cursor = MagicMock()
        cursor.fetchall.return_value = [
            {"id": 1, "name": "A", "email": "a@a.com", "cause": "x", "city": "y"},
        ]
        cursor.__enter__ = MagicMock(return_value=cursor)
        cursor.__exit__ = MagicMock(return_value=False)
        conn.cursor.return_value = cursor
        pool.getconn.return_value = conn

        resp = c.get("/ngos")
        assert resp.status_code == 200
        data = resp.get_json()
        assert isinstance(data, list)
        assert len(data) == 1
        pool.putconn.assert_called_once_with(conn)

    def test_get_ngos_internal_error(self, client):
        c, pool = client
        conn = MagicMock()
        cursor = MagicMock()
        cursor.execute.side_effect = RuntimeError("db down")
        cursor.__enter__ = MagicMock(return_value=cursor)
        cursor.__exit__ = MagicMock(return_value=False)
        conn.cursor.return_value = cursor
        pool.getconn.return_value = conn

        resp = c.get("/ngos")
        assert resp.status_code == 500
        pool.putconn.assert_called_once_with(conn)
