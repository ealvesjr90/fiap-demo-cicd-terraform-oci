import json
import os
import sys
import pytest
from unittest.mock import MagicMock, patch

# ---------------------------------------------------------------------------
# Mock the OCI SDK and required env vars BEFORE importing app.
# app.py runs OCI initialisation at module level, so mocks must be in place
# before the first import.
# ---------------------------------------------------------------------------

_mock_oci = MagicMock()
# ServiceError must be a real exception class so it can be used in except clauses.
# Use a lightweight subclass to avoid false isinstance() matches against base Exception.


class _MockServiceError(Exception):
    pass


_mock_oci.exceptions.ServiceError = _MockServiceError

sys.modules.setdefault("oci", _mock_oci)
sys.modules.setdefault("oci.auth", _mock_oci.auth)
sys.modules.setdefault("oci.auth.signers", _mock_oci.auth.signers)
sys.modules.setdefault("oci.queue", _mock_oci.queue)
sys.modules.setdefault("oci.nosql", _mock_oci.nosql)
sys.modules.setdefault("oci.nosql.models", _mock_oci.nosql.models)
sys.modules.setdefault("oci.config", _mock_oci.config)
sys.modules.setdefault("oci.exceptions", _mock_oci.exceptions)

os.environ.setdefault("OCI_QUEUE_ENDPOINT", "https://queue.fake.endpoint")
os.environ.setdefault("OCI_QUEUE_ID", "ocid1.queue.fake.id")
os.environ.setdefault("OCI_COMPARTMENT_ID", "ocid1.compartment.fake.id")

import app as analytics_app  # noqa: E402 (import after mocks)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def client():
    """Return a Flask test client for the analytics service."""
    analytics_app.app.config["TESTING"] = True
    with analytics_app.app.test_client() as test_client:
        yield test_client


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

def test_health_returns_200(client):
    """GET /health should respond with HTTP 200."""
    response = client.get("/health")
    assert response.status_code == 200


def test_health_returns_ok_status(client):
    """GET /health should return JSON body {"status": "ok"}."""
    response = client.get("/health")
    data = response.get_json()
    assert data is not None
    assert data["status"] == "ok"


def test_health_content_type_is_json(client):
    """GET /health should return application/json content type."""
    response = client.get("/health")
    assert "application/json" in response.content_type


def test_process_message_handles_invalid_json():
    """process_message should log an error and not crash on bad JSON."""
    message = MagicMock()
    message.id = "msg-001"
    message.content = "not-valid-json"

    # Should not raise; the function catches json.JSONDecodeError internally
    analytics_app.process_message(message)
    # No call to delete_message since JSON decode failed
    analytics_app.queue_client.delete_message.assert_not_called()


def test_process_message_stores_valid_event():
    """process_message should write to NoSQL and delete the message on success."""
    analytics_app.queue_client.reset_mock()
    analytics_app.nosql_client.reset_mock()

    message = MagicMock()
    message.id = "msg-002"
    message.content = json.dumps({
        "user_id": "user-1",
        "flag_name": "feature-x",
        "result": True,
        "timestamp": "2024-01-01T00:00:00Z",
    })

    analytics_app.process_message(message)

    analytics_app.nosql_client.put_row.assert_called_once()
    analytics_app.queue_client.delete_message.assert_called_once()
