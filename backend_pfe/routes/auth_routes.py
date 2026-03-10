from flask import Blueprint, request, jsonify, current_app
import jwt
from datetime import datetime, timedelta
from database.db import get_db_connection

bp = Blueprint("auth", __name__, url_prefix="/auth")


@bp.route("/signup", methods=["POST"])
def signup():

    data = request.json

    username = data["username"]
    email = data["email"]
    password = data["password"]
    role = data.get("role", "user")

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
    existing = cursor.fetchone()

    if existing:
        return jsonify({"message": "Utilisateur existe déjà"}), 400

    cursor.execute(
        "INSERT INTO users (full_name,email,password,role) VALUES (%s,%s,%s,%s)",
        (username, email, password, role)
    )

    db.commit()

    cursor.close()
    db.close()

    return jsonify({"message": "Utilisateur créé"}), 201


@bp.route("/signin", methods=["POST"])
def signin():
    try:
        data = request.json
        email = data["email"]
        password = data["password"]

        db = get_db_connection()
        cursor = db.cursor(dictionary=True, buffered=True)  # <- ajouté buffered=True
        cursor.execute(
            "SELECT * FROM users WHERE email=%s AND password=%s",
            (email, password)
        )
        user = cursor.fetchone()

        cursor.close()
        db.close()

        if user:
            token = jwt.encode({
                "user_id": user["id"],
                "username": user["full_name"],
                "email": user["email"],
                "role": user["role"],
                "exp": datetime.utcnow() + timedelta(hours=2)
            }, current_app.config['SECRET_KEY'], algorithm="HS256")

            return jsonify({
                "message": "Login successful",
                "user_id": user["id"],
                "username": user["full_name"],
                "email": user["email"],
                "role": user["role"],
                "token": token
            }), 200
        else:
            return jsonify({"message": "Email ou mot de passe invalide"}), 401

    except Exception as e:
        return jsonify({"error": str(e)}), 500