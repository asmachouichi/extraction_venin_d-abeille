from flask import Blueprint, jsonify
from extensions import mysql


admin = Blueprint("admin", __name__)



@admin.route("/admin/statistics", methods=["GET"])
def statistics():


    cur = mysql.connection.cursor()


    # Users
    cur.execute(
        "SELECT COUNT(*) FROM users"
    )

    users = cur.fetchone()[0]



    # Extractions
    cur.execute(
        """
        SELECT COUNT(*)
        FROM extractions
        WHERE status='stopped'
        """
    )

    extractions = cur.fetchone()[0]



    # Alertes
    cur.execute(
        """
        SELECT COUNT(*)
        FROM alerts
        """
    )

    alerts = cur.fetchone()[0]



    cur.close()



    return jsonify({

        "users": users,

        "extractions": extractions,

        "alerts": alerts

    })