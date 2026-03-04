import serial
import pandas as pd
import os
from datetime import datetime
from serial.tools import list_ports


#  Détection automatique ESP32

def detect_esp32():
    ports = list_ports.comports()
    for p in ports:
        if "CP210" in p.description or "CH340" in p.description or "USB" in p.description:
            return p.device
    return None

PORT = detect_esp32()
BAUDRATE = 115200
CSV_FILE = "dataset_venin.csv"

if PORT is None:
    print("ESP32 non détecté.")
    exit()

print("ESP32 détecté sur :", PORT)


#  Création CSV si absent

columns = ["timestamp", "poids", "temperature_sht", "humidite_sht"]

if not os.path.exists(CSV_FILE):
    df_init = pd.DataFrame(columns=columns)
    df_init.to_csv(CSV_FILE, index=False)


#  Connexion série

ser = serial.Serial(PORT, BAUDRATE, timeout=1)
print("Lecture des données...")

try:
    while True:
        line = ser.readline().decode("utf-8").strip()
        if not line or "," not in line:
            continue

        parts = line.split(",")

        if len(parts) != 3:
            print("Ligne ignorée (nombre de valeurs incorrect):", line)
            continue

        try:
            poids = float(parts[0])
            temperature_sht = float(parts[1])
            humidite_sht = float(parts[2])
        except ValueError:
            print("Erreur conversion :", line)
            continue

        # Création de la nouvelle ligne
        new_row = pd.DataFrame([{
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "poids": poids,
            "temperature_sht": temperature_sht,
            "humidite_sht": humidite_sht
        }])

        # Append direct au CSV
        new_row.to_csv(CSV_FILE, mode='a', header=False, index=False)

        print(f"Donnée enregistrée ✔ : Poids={poids}, Temp={temperature_sht}, Hum={humidite_sht}")

except KeyboardInterrupt:
    print("Arrêt du programme")
    ser.close()