from flask import Flask, request
import csv
from datetime import datetime

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload():
    data = request.json

    # Affiche les données dans le terminal Flask
    print("Reçu :", data)

    with open("data.csv", "a", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            datetime.now(),
            data.get("weight"),
            data.get("temp"),
            data.get("hum"),
            data.get("ax"),
            data.get("ay"),
            data.get("az"),
            data.get("gx"),
            data.get("gy"),
            data.get("gz"),
            data.get("mx"),
            data.get("my"),
            data.get("mz")
        ])

    return "OK"

app.run(host="0.0.0.0", port=5000)