from flask import Blueprint, jsonify, request
from extensions import mysql



users_bp = Blueprint(
    "users",
    __name__
)



# ==============================
# Afficher utilisateurs
# ==============================

@users_bp.route(
"/admin/users",
methods=["GET"]
)
def get_users():


    cur = mysql.connection.cursor()


    cur.execute(
        """
        SELECT id,username,email,role
        FROM users
        """
    )


    data = cur.fetchall()


    cur.close()



    users=[]


    for u in data:

        users.append({

            "id":u[0],
            "username":u[1],
            "email":u[2],
            "role":u[3]

        })


    return jsonify(users)






# ==============================
# Ajouter utilisateur
# ==============================


@users_bp.route(
"/admin/users",
methods=["POST"]
)
def add_user():


    data=request.json


    username=data["username"]

    email=data["email"]

    password=data["password"]

    role=data["role"]



    cur=mysql.connection.cursor()



    cur.execute(

    """
    INSERT INTO users
    (
    username,
    email,
    password,
    role
    )

    VALUES(%s,%s,%s,%s)

    """,

    (
    username,
    email,
    password,
    role
    )

    )



    mysql.connection.commit()


    cur.close()



    return jsonify({

        "message":"Utilisateur ajouté"

    }),201







# ==============================
# Modifier utilisateur
# ==============================


@users_bp.route(
"/admin/users/<int:id>",
methods=["PUT"]
)
def update_user(id):


    data=request.json


    cur=mysql.connection.cursor()



    cur.execute(

    """
    UPDATE users

    SET username=%s,
        email=%s,
        role=%s

    WHERE id=%s

    """,

    (

    data["username"],

    data["email"],

    data["role"],

    id

    )

    )



    mysql.connection.commit()


    cur.close()



    return jsonify({

        "message":"Utilisateur modifié"

    })








# ==============================
# Supprimer utilisateur
# ==============================


@users_bp.route(
"/admin/users/<int:id>",
methods=["DELETE"]
)
def delete_user(id):


    cur=mysql.connection.cursor()



    cur.execute(

    """
    DELETE FROM users
    WHERE id=%s
    """,

    (id,)

    )



    mysql.connection.commit()


    cur.close()



    return jsonify({

        "message":"Utilisateur supprimé"

    })