from flask import Blueprint, jsonify
from extensions import mysql


alerts = Blueprint(
    "alerts",
    __name__
)



# Afficher les alertes ADMIN (sans doublons)


@alerts.route(
    "/admin/alerts",
    methods=["GET"]
)
def get_alerts():

    cur = mysql.connection.cursor()


    cur.execute("""
        SELECT

        a.id,
        a.user_id,
        u.username,
        a.type,
        a.message,
        a.severity,
        a.status,
        a.created_at

        FROM alerts a

        LEFT JOIN users u

        ON a.user_id = u.id

        WHERE a.id IN (

            SELECT MAX(id)

            FROM alerts

            GROUP BY user_id, type

        )

        ORDER BY a.created_at DESC

        LIMIT 50

    """)


    rows = cur.fetchall()


    cur.close()


    alerts_list = []


    for r in rows:

        alerts_list.append({

            "id": r[0],

            "user_id": r[1],

            "username": r[2] if r[2] else "Inconnu",

            "type": r[3],

            "message": r[4],

            "severity": r[5],

            "status": r[6],

            "created_at": str(r[7])

        })


    return jsonify(alerts_list), 200





# =====================================================
# Marquer une alerte comme lue
# =====================================================

@alerts.route(
    "/admin/alerts/read/<int:id>",
    methods=["PUT"]
)
def read_alert(id):

    cur = mysql.connection.cursor()


    cur.execute("""
        UPDATE alerts

        SET status='read'

        WHERE id=%s

    """, (id,))


    mysql.connection.commit()


    cur.close()


    return jsonify({

        "message":
        "Alerte marquée comme lue"

    }), 200





# =====================================================
# Supprimer définitivement une alerte
# =====================================================

@alerts.route(
    "/admin/alerts/<int:id>",
    methods=["DELETE"]
)
def delete_alert(id):

    cur = mysql.connection.cursor()


    cur.execute("""
        DELETE FROM alerts

        WHERE id=%s

    """, (id,))


    mysql.connection.commit()


    cur.close()


    return jsonify({

        "message":
        "Alerte supprimée définitivement"

    }), 200