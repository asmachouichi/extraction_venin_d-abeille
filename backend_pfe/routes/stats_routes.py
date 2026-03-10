from flask import Blueprint, jsonify
from database.db import get_db_connection
from utils.auth_middleware import token_required

bp = Blueprint("stats", __name__, url_prefix="/stats")


@bp.route("/user", methods=["GET"])
@token_required
def user_stats(current_user):

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        "SELECT COUNT(*) as total FROM extractions WHERE user_id=%s",
        (current_user["user_id"],)
    )

    total_extraction = cursor.fetchone()["total"]

    cursor.execute(
        "SELECT SUM(quantity) as total_venom FROM extractions WHERE user_id=%s",
        (current_user["user_id"],)
    )

    venom = cursor.fetchone()["total_venom"]

    cursor.close()
    db.close()

    return jsonify({
        "total_extraction": total_extraction,
        "total_venom": venom
    })
