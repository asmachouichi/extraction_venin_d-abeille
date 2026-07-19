from flask import Blueprint, request, jsonify
import csv
import os
from datetime import datetime

bp = Blueprint("sensor", __name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_FILE = os.path.join(BASE_DIR, "sensors.csv")


# ================= CREATE CSV =================
if not os.path.exists(CSV_FILE):
    with open(CSV_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "timestamp",
            "weight",
            "temperature",
            "humidity",
            "vibration"
        ])


# ================= POST SENSOR =================
@bp.route("", methods=["POST"])
def add_sensor():

    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "No data received"}), 400

        with open(CSV_FILE, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)

            writer.writerow([
                datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                data.get("weight", 0),
                data.get("temperature", 0),
                data.get("humidity", 0),
                data.get("vibration", 0)
            ])

        print("CSV SAVED:", data)

        return jsonify({"message": "saved"}), 201

    except Exception as e:
        print("POST ERROR:", e)
        return jsonify({"error": str(e)}), 500


# ================= GET ALL =================
@bp.route("/", methods=["GET"])
def get_sensors():

    try:
        rows = []

        with open(CSV_FILE, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            rows = list(reader)

        return jsonify(rows), 200

    except Exception as e:
        print("GET ERROR:", e)
        return jsonify({"error": str(e)}), 500


# ================= GET LAST VALUE (FIXED) =================
@bp.route("/last", methods=["GET"])
def last_sensor():

    try:
        with open(CSV_FILE, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            rows = list(reader)

        if len(rows) == 0:
            return jsonify({
                "weight": 0,
                "temperature": 0,
                "humidity": 0,
                "vibration": 0
            }), 200

        last = rows[-1]

        # 🔥 FORCE SAFE FORMAT (IMPORTANT)
        return jsonify({
            "weight": float(last.get("weight", 0)),
            "temperature": float(last.get("temperature", 0)),
            "humidity": float(last.get("humidity", 0)),
            "vibration": float(last.get("vibration", 0))
        }), 200

    except Exception as e:
        print("LAST ERROR:", e)
        return jsonify({"error": str(e)}), 500