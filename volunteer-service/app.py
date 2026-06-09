import os
import sys
import uuid
import time

import oci
from flask import request, jsonify
from solidarytech.flask_utils import (
    setup_logging,
    require_env,
    create_flask_app,
    validate_required_fields,
    error_response,
    run_app,
)

log = setup_logging()
app = create_flask_app("volunteer-service")

OCI_REGION = os.getenv("OCI_REGION", "sa-saopaulo-1")
NOSQL_COMPARTMENT_ID = require_env("OCI_NOSQL_COMPARTMENT_ID", log)
NOSQL_TABLE_NAME = os.getenv("OCI_NOSQL_TABLE_NAME", "togglemaster_table")


def get_nosql_client():
    try:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        return oci.nosql.NosqlClient(config={}, signer=signer)
    except Exception:
        log.info("Instance Principal indisponivel, usando config file (~/.oci/config)")

    try:
        config = oci.config.from_file()
        return oci.nosql.NosqlClient(config)
    except Exception as e:
        log.critical("Falha ao configurar OCI NoSQL client: %s", e)
        sys.exit(1)


nosql_client = get_nosql_client()
log.info("Conectado ao OCI NoSQL - Tabela: %s", NOSQL_TABLE_NAME)


@app.route('/volunteers', methods=['POST'])
def register_volunteer():
    data = request.get_json()
    err = validate_required_fields(data, ('name', 'email', 'ngo_id'))
    if err:
        return err

    volunteer_id = str(uuid.uuid4())
    row_value = {
        'id': volunteer_id,
        'name': data['name'],
        'email': data['email'],
        'ngo_id': str(data['ngo_id']),
        'registered_at': str(int(time.time()))
    }

    try:
        nosql_client.update_row(
            table_name_or_id=NOSQL_TABLE_NAME,
            update_row_details=oci.nosql.models.UpdateRowDetails(
                value=row_value,
                compartment_id=NOSQL_COMPARTMENT_ID
            )
        )
        return jsonify(row_value), 201
    except Exception as e:
        log.error("Erro ao salvar voluntario no OCI NoSQL: %s", e)
        return error_response("Erro interno ao processar dados")


@app.route('/volunteers/<int:ngo_id>', methods=['GET'])
def get_volunteers_by_ngo(ngo_id):
    try:
        statement = "SELECT * FROM {} WHERE ngo_id = '{}'".format(  # nosec B608
            NOSQL_TABLE_NAME, ngo_id)
        response = nosql_client.query(
            query_details=oci.nosql.models.QueryDetails(
                compartment_id=NOSQL_COMPARTMENT_ID,
                statement=statement,
                consistency="EVENTUAL"
            )
        )
        items = [row for row in (response.data.items or [])]
        return jsonify(items), 200
    except Exception as e:
        log.error("Erro ao buscar dados no OCI NoSQL: %s", e)
        return error_response("Erro interno")


if __name__ == '__main__':
    run_app(app, 8083)
