from flask import request, jsonify, current_app
import jwt
from functools import wraps


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        token = request.headers.get("Authorization")

        if not token:
            return jsonify({"message": "Token manquant"}), 401

        try:
            token = token.split(" ")[1]

            data = jwt.decode(
                token,
                current_app.config["SECRET_KEY"],
                algorithms=["HS256"]
            )

        except:
            return jsonify({"message": "Token invalide"}), 401

        return f(data, *args, **kwargs)

    return decorated


def admin_required(f):
    @wraps(f)
    def decorated(current_user, *args, **kwargs):

        if current_user["role"] != "admin":
            return jsonify({"message": "Admin seulement"}), 403

        return f(current_user, *args, **kwargs)

    return decorated