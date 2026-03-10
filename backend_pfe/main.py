from flask import Flask, request, jsonify
import pandas as pd
from datetime import datetime
import os

app = Flask(__name__)

CSV_FILE = "dataset_venin_wifi.csv"

# Créer le fichier CSV avec header si n'existe pas
if not os.path.exists(CSV_FILE):
    df = pd.DataFrame(columns=[
        "timestamp", "poids", "temperature", "humidite",
        "ax", "ay", "az",
        "gx", "gy", "gz",
        "mx", "my", "mz"
    ])
    df.to_csv(CSV_FILE, index=False)

@app.route("/")
def index():
    return jsonify({"message": "Serveur Flask en ligne, prêt à recevoir des données WiFi."})

@app.route("/iot_data", methods=["POST"])
def receive_data():
    try:
        data = request.get_json()

        # Ajouter le timestamp côté serveur
        data["timestamp"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Sauvegarder dans CSV
        pd.DataFrame([data]).to_csv(CSV_FILE, mode="a", header=False, index=False)

        print("Données reçues :", data)
        return jsonify({"status": "success"}), 200

    except Exception as e:
        print("Erreur réception données :", e)
        return jsonify({"status": "error", "message": str(e)}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)