import os
import requests
import logging
from functools import wraps
from flask import request, jsonify

log = logging.getLogger(__name__)


def require_auth(f):
    """ Middleware para validar a chave de API contra o auth-service """
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            return jsonify({"error": "Authorization header obrigatório"}), 401

        auth_service_url = os.getenv("AUTH_SERVICE_URL")
        if not auth_service_url:
            log.error("AUTH_SERVICE_URL não está configurado")
            return jsonify({"error": "Serviço de autenticação indisponível"}), 503
        try:
            validate_url = f"{auth_service_url}/validate"
            response = requests.get(validate_url, headers={"Authorization": auth_header}, timeout=3)

            if response.status_code != 200:
                log.warning(f"Falha na validação da chave (status: {response.status_code})")
                return jsonify({"error": "Chave de API inválida"}), 401

        except requests.exceptions.Timeout:
            log.error("Timeout ao conectar com o auth-service")
            return jsonify({"error": "Serviço de autenticação indisponível (timeout)"}), 504  # Gateway Timeout
        except requests.exceptions.RequestException as e:
            log.error(f"Erro ao conectar com o auth-service: {e}")
            return jsonify({"error": "Serviço de autenticação indisponível"}), 503  # Service Unavailable

        return f(*args, **kwargs)
    return decorated
