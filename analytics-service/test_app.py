import json
from unittest.mock import MagicMock, patch

import pytest
import app as analytics_app


class TestHealthEndpoint:
    def test_health_returns_200(self, client):
        response = client.get("/health")
        assert response.status_code == 200

    def test_health_returns_ok_status(self, client):
        response = client.get("/health")
        data = json.loads(response.data)
        assert data["status"] == "ok"


class TestProcessMessage:
    def test_valid_message_inserts_row_and_deletes(self):
        message = MagicMock()
        message.id = "msg-001"
        message.receipt = "receipt-001"
        message.content = json.dumps({
            "user_id": "user-1",
            "flag_name": "feature-x",
            "result": True,
            "timestamp": "2026-01-01T00:00:00Z",
        })

        with patch("oci.nosql.models.PutRowDetails", MagicMock(), create=True):
            analytics_app.process_message(message)

        analytics_app.nosql_client.put_row.assert_called_once()
        analytics_app.queue_client.delete_message.assert_called_once_with(
            queue_id=analytics_app.OCI_QUEUE_ID,
            message_receipt="receipt-001",
        )

    def test_invalid_json_does_not_delete_message(self):
        message = MagicMock()
        message.id = "msg-002"
        message.content = "not valid json"

        analytics_app.process_message(message)

        analytics_app.nosql_client.put_row.assert_not_called()
        analytics_app.queue_client.delete_message.assert_not_called()

    def test_nosql_error_does_not_delete_message(self):
        import oci

        message = MagicMock()
        message.id = "msg-003"
        message.content = json.dumps({
            "user_id": "user-1",
            "flag_name": "feature-x",
            "result": True,
            "timestamp": "2026-01-01T00:00:00Z",
        })

        analytics_app.nosql_client.put_row.side_effect = oci.exceptions.ServiceError(
            status=500,
            code="InternalServerError",
            headers={},
            message="OCI error",
        )

        analytics_app.process_message(message)

        analytics_app.queue_client.delete_message.assert_not_called()
