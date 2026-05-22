from flask import Blueprint, request, jsonify
from extensions import mysql

bp = Blueprint("sensor", __name__)


# 📥 ADD SENSOR DATA (ESP32 / Arduino)

@bp.route("/", methods=["POST"])
def add_sensor():

    try:
        data = request.json

        weight = data.get("weight")
        temperature = data.get("temperature")
        humidity = data.get("humidity")
        ax = data.get("ax")
        ay = data.get("ay")
        az = data.get("az")

        cur = mysql.connection.cursor()

        cur.execute("""
            INSERT INTO sensors(weight, temperature, humidity, ax, ay, az)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (weight, temperature, humidity, ax, ay, az))

        mysql.connection.commit()
        cur.close()

        return jsonify({
            "message": "Sensor data saved successfully"
        }), 201

    except Exception as e:
        return jsonify({
            "message": "Error saving sensor data",
            "error": str(e)
        }), 500



# 📊 GET SENSOR DATA (FLUTTER DASHBOARD)

@bp.route("/", methods=["GET"])
def get_sensors():

    try:
        cur = mysql.connection.cursor()

        cur.execute("""
            SELECT weight, temperature, humidity, ax, ay, az
            FROM sensors
            ORDER BY id DESC
            LIMIT 20
        """)

        rows = cur.fetchall()
        cur.close()

        result = []

        for r in rows:
            result.append({
                "weight": float(r[0]),
                "temperature": float(r[1]),
                "humidity": float(r[2]),
                "ax": float(r[3]),
                "ay": float(r[4]),
                "az": float(r[5])
            })

        return jsonify(result), 200

    except Exception as e:
        return jsonify({
            "message": "Error fetching sensor data",
            "error": str(e)
        }), 500