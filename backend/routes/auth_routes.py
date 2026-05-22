from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from flask_bcrypt import Bcrypt
from extensions import mysql

bp = Blueprint("auth", __name__)
bcrypt = Bcrypt()

# ================= SIGNUP =================
@bp.route("/auth/signup", methods=["POST"])
def signup():

    data = request.json

    username = data["username"]
    email = data["email"]
    password = data["password"]

    cur = mysql.connection.cursor()

    # check user exists
    cur.execute("SELECT * FROM users WHERE email=%s", (email,))
    user = cur.fetchone()

    if user:
        return jsonify({"message": "User already exists"}), 400

    # hash password
    hashed_pw = bcrypt.generate_password_hash(password).decode('utf-8')

    # insert user
    cur.execute(
        "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)",
        (username, email, hashed_pw)
    )

    mysql.connection.commit()
    cur.close()

    return jsonify({"message": "User created successfully"}), 201


# ================= LOGIN =================
@bp.route("/auth/signin", methods=["POST"])
def signin():

    data = request.json

    email = data["email"]
    password = data["password"]

    cur = mysql.connection.cursor()

    cur.execute("SELECT * FROM users WHERE email=%s", (email,))
    user = cur.fetchone()

    if not user:
        return jsonify({"message": "User not found"}), 404

    db_password = user[3]

    if not bcrypt.check_password_hash(db_password, password):
        return jsonify({"message": "Wrong password"}), 401

    token = create_access_token(identity=email)

    return jsonify({
        "message": "Login success",
        "token": token,
        "username": user[1],
        "email": user[2],
        "role": user[4]
    }), 200