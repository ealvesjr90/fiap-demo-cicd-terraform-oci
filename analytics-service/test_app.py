import json
import pytest
from unittest.mock import MagicMock, patch


@pytest.fixture(autouse=True)
def mock_oci_env(monkeypatch):
    monkeypatch.setenv("OCI_QUEUE_ENDPOINT", "https://queue.example.invalid")
    monkeypatch.setenv("OCI_QUEUE_ID", "ocid1.queue.oc1.test")
    monkeypatch.setenv("OCI_COMPARTMENT_ID", "ocid1.compartment.oc1.test")


@pytest.fixture
def client():
    with patch("oci.auth.signers.get_resource_principals_signer", side_effect=Exception("no rp")), \
         patch("oci.config.from_file", return_value={}), \
         patch("oci.queue.QueueClient", return_value=MagicMock()), \
         patch("oci.nosql.NosqlClient", return_value=MagicMock()):
        import importlib
        import app as analytics_app
        importlib.reload(analytics_app)
        analytics_app.app.config["TESTING"] = True
        with analytics_app.app.test_client() as c:
            yield c


def test_health_status_code(client):
    response = client.get("/health")
    assert response.status_code == 200  # nosec B101


def test_health_response_body(client):
    response = client.get("/health")
    data = json.loads(response.data)
    assert data["status"] == "ok"  # nosec B101
