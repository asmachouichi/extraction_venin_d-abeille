from flask import Blueprint, request, jsonify
from database.db import get_db_connection
from utils.auth_middleware import token_required
from datetime import datetime
import serial

bp = Blueprint("extraction", __name__, url_prefix="/extraction")

# connexion IoT (Arduino / ESP32)
try:
    ser = serial.Serial('COM4', 115200, timeout=1)
    print("IoT connecté sur COM4")
except:
    ser = None
    print("IoT non connecté")

# ------------------- DEMARRER EXTRACTION -------------------

@bp.route("/start", methods=["POST"])
@token_required
def start_extraction(current_user):
    try:

        # envoyer commande IoT
        if ser:
            ser.write(b"START\n")

        db = get_db_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            "INSERT INTO extractions (user_id, quantity, extraction_date) VALUES (%s,%s,%s)",
            (current_user["user_id"], 0, datetime.now())
        )

        db.commit()

        extraction_id = cursor.lastrowid

        cursor.close()
        db.close()

        return jsonify({
            "message": "Extraction démarrée",
            "extraction_id": extraction_id
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ------------------- ARRETER EXTRACTION -------------------

@bp.route("/stop", methods=["POST"])
@token_required
def stop_extraction(current_user):
    try:
        data = request.json
        extraction_id = data.get("extraction_id")

        if extraction_id is None:
            return jsonify({"error": "Paramètres manquants"}), 400

        db = get_db_connection()
        cursor = db.cursor(dictionary=True)

        # Vérifier l'extraction
        cursor.execute(
            "SELECT * FROM extractions WHERE id=%s AND user_id=%s",
            (extraction_id, current_user["user_id"])
        )
        extraction = cursor.fetchone()
        if not extraction:
            cursor.close()
            db.close()
            return jsonify({"error": "Extraction introuvable"}), 404

        # ---------------- IoT : envoyer STOP ----------------
        final_quantity = 0
        if ser:
            ser.write(b"STOP\n")
            # attendre et lire le poids final
            while True:
                line = ser.readline().decode("utf-8").strip()
                if line.startswith("FINAL_WEIGHT"):
                    final_quantity = float(line.split(",")[1])
                    break

        # ---------------- Mise à jour DB ----------------
        cursor.execute(
            "UPDATE extractions SET quantity=%s, status='stopped' WHERE id=%s",
            (final_quantity, extraction_id)
        )
        db.commit()

        cursor.close()
        db.close()

        return jsonify({
            "message": "Extraction arrêtée",
            "quantity": final_quantity
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500