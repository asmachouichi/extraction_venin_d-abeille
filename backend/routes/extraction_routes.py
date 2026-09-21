from flask import Blueprint, jsonify
from extensions import mysql

extractions_bp = Blueprint("extractions", __name__)

@extractions_bp.route("/admin/extractions", methods=["GET"])
def get_extractions():

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT
            e.id,
            u.username,
            e.quantity,
            e.extraction_date,
            e.status
        FROM extractions e
        JOIN users u
            ON e.user_id = u.id
        ORDER BY e.extraction_date DESC
    """)

    rows = cur.fetchall()
    cur.close()

    data = []

    for row in rows:
        data.append({
            "id": row[0],
            "username": row[1],
            "quantity": row[2],
            "date": str(row[3]),
            "status": row[4]
        })

    return jsonify(data), 200