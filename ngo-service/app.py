import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from psycopg2.pool import SimpleConnectionPool
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
app = create_flask_app("ngo-service")

DATABASE_URL = require_env("DATABASE_URL", log)

try:
    pool = SimpleConnectionPool(1, 10, dsn=DATABASE_URL)
    log.info("Pool de conexões com o PostgreSQL (ngo-service) inicializado.")
except Exception as e:
    log.critical("Erro ao conectar ao PostgreSQL: %s", e)
    sys.exit(1)


@app.route('/ngos', methods=['POST'])
def create_ngo():
    data = request.get_json()
    err = validate_required_fields(data, ('name', 'email', 'cause', 'city'))
    if err:
        return err

    conn = pool.getconn()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "INSERT INTO ngos (name, email, cause, city) VALUES (%s, %s, %s, %s) RETURNING *",
                (data['name'], data['email'], data['cause'], data['city'])
            )
            new_ngo = cur.fetchone()
            conn.commit()
            return jsonify(new_ngo), 201
    except psycopg2.IntegrityError:
        conn.rollback()
        return error_response("E-mail já cadastrado", 409)
    except Exception as e:
        conn.rollback()
        log.error("Erro ao criar ONG: %s", e)
        return error_response("Erro interno")
    finally:
        pool.putconn(conn)


@app.route('/ngos', methods=['GET'])
def get_ngos():
    conn = pool.getconn()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT * FROM ngos ORDER BY id DESC")
            return jsonify(cur.fetchall()), 200
    except Exception as e:
        log.error("Erro ao buscar ONGs: %s", e)
        return error_response("Erro interno")
    finally:
        pool.putconn(conn)


if __name__ == '__main__':
    run_app(app, 8081)
