"""Unit tests for the Volunteer service Flask application."""

import json
import os
import sys
from unittest.mock import MagicMock, patch

import pytest

os.environ.setdefault("AWS_DYNAMODB_TABLE", "TestVolunteers")
os.environ.setdefault("AWS_REGION", "us-east-1")


@pytest.fixture()
def client():
    """Create a Flask test client with DynamoDB mocked."""
    mock_table = MagicMock()
    mock_dynamo = MagicMock()
    mock_dynamo.Table.return_value = mock_table

    with patch("boto3.resource", return_value=mock_dynamo), \
         patch("boto3.dynamodb.conditions.Attr") as mock_attr:
        # Make Attr("ngo_id").eq(x) return a mock filter expression
        mock_attr.return_value.eq.return_value = "mock_filter"

        sys.modules.pop("app", None)
        import app as vol_app

        vol_app.app.config["TESTING"] = True
        vol_app.table = mock_table
        with vol_app.app.test_client() as c:
            yield c, mock_table


# ── /health ──────────────────────────────────────────────────────────


class TestHealthEndpoint:
    def test_health_returns_ok(self, client):
        c, _ = client
        resp = c.get("/health")
        assert resp.status_code == 200
        data = resp.get_json()
        assert data["status"] == "ok"
        assert data["service"] == "volunteer-service"


# ── POST /volunteers ─────────────────────────────────────────────────


class TestRegisterVolunteer:
    def test_register_success(self, client):
        c, table = client
        resp = c.post(
            "/volunteers",
            data=json.dumps({"name": "Ana", "email": "ana@x.com", "ngo_id": "1"}),
            content_type="application/json",
        )
        assert resp.status_code == 201
        data = resp.get_json()
        assert data["name"] == "Ana"
        assert data["email"] == "ana@x.com"
        assert "volunteer_id" in data
        assert "registered_at" in data
        table.put_item.assert_called_once()

    def test_register_missing_fields(self, client):
        c, _ = client
        resp = c.post(
            "/volunteers",
            data=json.dumps({"name": "Ana"}),
            content_type="application/json",
        )
        assert resp.status_code == 400
        assert "obrigat" in resp.get_json()["error"].lower()

    def test_register_empty_body(self, client):
        c, _ = client
        resp = c.post("/volunteers", content_type="application/json")
        assert resp.status_code == 400

    def test_register_dynamo_error(self, client):
        c, table = client
        table.put_item.side_effect = RuntimeError("dynamo down")

        resp = c.post(
            "/volunteers",
            data=json.dumps({"name": "Bob", "email": "b@x.com", "ngo_id": "2"}),
            content_type="application/json",
        )
        assert resp.status_code == 500
        assert "erro" in resp.get_json()["error"].lower()


# ── GET /volunteers/<ngo_id> ─────────────────────────────────────────


class TestGetVolunteersByNgo:
    def test_get_volunteers_success(self, client):
        c, table = client
        table.scan.return_value = {
            "Items": [
                {"volunteer_id": "abc", "name": "Ana", "email": "a@a.com", "ngo_id": 1},
            ],
        }

        resp = c.get("/volunteers/1")
        assert resp.status_code == 200
        data = resp.get_json()
        assert isinstance(data, list)
        assert len(data) == 1
        assert data[0]["name"] == "Ana"

    def test_get_volunteers_empty(self, client):
        c, table = client
        table.scan.return_value = {"Items": []}

        resp = c.get("/volunteers/999")
        assert resp.status_code == 200
        assert resp.get_json() == []

    def test_get_volunteers_dynamo_error(self, client):
        c, table = client
        table.scan.side_effect = RuntimeError("scan failed")

        resp = c.get("/volunteers/1")
        assert resp.status_code == 500
        assert "erro" in resp.get_json()["error"].lower()
