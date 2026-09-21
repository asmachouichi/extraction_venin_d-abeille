from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from flask_bcrypt import Bcrypt
from extensions import mysql


bp = Blueprint("auth", __name__)

bcrypt = Bcrypt()


# ================= ADMIN FIXE =================

ADMIN_USERNAME = "Administrateur"
ADMIN_EMAIL = "admin@gmail.com"
ADMIN_PASSWORD = "123456"
ADMIN_ROLE = "admin"



# ================= SIGNUP =================

@bp.route("/auth/signup", methods=["POST"])
def signup():

    data = request.json

    username = data["username"]
    email = data["email"]
    password = data["password"]


    cur = mysql.connection.cursor()


    # Vérifier si utilisateur existe

    cur.execute(
        "SELECT * FROM users WHERE email=%s",
        (email,)
    )

    user = cur.fetchone()


    if user:

        cur.close()

        return jsonify({
            "message":"User already exists"
        }),400



    # Hash password

    hashed_pw = bcrypt.generate_password_hash(
        password
    ).decode('utf-8')



    # Ajouter utilisateur avec role user

    cur.execute(
        """
        INSERT INTO users
        (username,email,password,role)
        VALUES (%s,%s,%s,%s)
        """,
        (
            username,
            email,
            hashed_pw,
            "user"
        )
    )


    mysql.connection.commit()

    cur.close()



    return jsonify({

        "message":
        "User created successfully"

    }),201





# ================= LOGIN =================

@bp.route("/auth/signin", methods=["POST"])
def signin():


    data = request.json


    email = data["email"]

    password = data["password"]



    # ==================================================
    #                 ADMIN LOGIN FIXE
    # ==================================================


    if (
        email == ADMIN_EMAIL
        and password == ADMIN_PASSWORD
    ):


        token = create_access_token(
            identity=email
        )


        return jsonify({

            "message":
            "Admin Login success",


            "token":
            token,


            "username":
            ADMIN_USERNAME,


            "email":
            ADMIN_EMAIL,


            "role":
            ADMIN_ROLE

        }),200




    # ==================================================
    #                 USER LOGIN MYSQL
    # ==================================================


    cur = mysql.connection.cursor()


    cur.execute(
        "SELECT * FROM users WHERE email=%s",
        (email,)
    )


    user = cur.fetchone()



    if not user:

        cur.close()

        return jsonify({

            "message":
            "User not found"

        }),404




    # Structure table:
    # id | username | email | password | role


    db_password = user[3]



    # Vérification password

    if not bcrypt.check_password_hash(
        db_password,
        password
    ):


        cur.close()


        return jsonify({

            "message":
            "Wrong password"

        }),401




    token = create_access_token(
        identity=email
    )



    cur.close()



    return jsonify({

        "message":
        "Login success",


        "token":
        token,


        "username":
        user[1],


        "email":
        user[2],


        "role":
        user[4]

    }),200