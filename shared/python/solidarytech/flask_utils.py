"""Shared Flask utilities for SolidaryTech microservices.

Eliminates boilerplate duplication across Python services by providing
common patterns for app creation, logging, validation, and error handling.
"""

import os
import sys
import logging

from flask import Flask, jsonify


def setup_logging():
    """Configure standard logging format used across all services."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    return logging.getLogger(__name__)


def require_env(name, logger):
    """Read a required environment variable or exit with a critical log."""
    value = os.getenv(name)
    if not value:
        logger.critical("Erro: %s não definida.", name)
        sys.exit(1)
    return value


def create_flask_app(service_name):
    """Create a Flask app with dotenv loading and a /health endpoint."""
    from dotenv import load_dotenv

    load_dotenv()

    app = Flask(service_name)

    @app.route("/health")
    def health():
        return jsonify({"status": "ok", "service": service_name})

    return app


def validate_required_fields(data, required_fields):
    """Return a 400 error tuple if any required field is missing, else None."""
    if not data or not all(k in data for k in required_fields):
        return jsonify({"error": "Campos obrigatórios ausentes"}), 400
    return None


def error_response(message, status_code=500):
    """Return a JSON error response."""
    return jsonify({"error": message}), status_code


def run_app(app, default_port):
    """Run the Flask app on 0.0.0.0 with PORT from env or the given default."""
    port = int(os.getenv("PORT", default_port))
    app.run(host="0.0.0.0", port=port)
