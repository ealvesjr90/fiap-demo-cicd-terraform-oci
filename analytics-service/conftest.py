import os
from unittest.mock import MagicMock

# Set TESTING before any app imports to prevent OCI initialization
os.environ["TESTING"] = "1"
os.environ.setdefault("OCI_QUEUE_ENDPOINT", "https://fake-queue.oci.test")
os.environ.setdefault("OCI_QUEUE_ID", "ocid1.queue.oc1.fake")
os.environ.setdefault("OCI_COMPARTMENT_ID", "ocid1.compartment.oc1.fake")
os.environ.setdefault("OCI_REGION", "us-ashburn-1")

import pytest
import app as analytics_app


@pytest.fixture(autouse=True)
def mock_oci_clients():
    """Inject mock OCI clients into the app module for each test."""
    analytics_app.queue_client = MagicMock()
    analytics_app.nosql_client = MagicMock()
    yield
    analytics_app.queue_client = None
    analytics_app.nosql_client = None


@pytest.fixture
def client():
    analytics_app.app.config["TESTING"] = True
    with analytics_app.app.test_client() as c:
        yield c
