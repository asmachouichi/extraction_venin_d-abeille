# run_all.py
import subprocess
import os
import signal

# Récupérer le dossier courant
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Chemins vers les scripts
APP_PY = os.path.join(BASE_DIR, "app.py")
MAIN_PY = os.path.join(BASE_DIR, "main.py")

# Lancer Flask
flask_proc = subprocess.Popen(["python", APP_PY])

# Lancer ESP32 reader
esp_proc = subprocess.Popen(["python", MAIN_PY])

print("Backend Flask et ESP32 reader lancés en parallèle.")

try:
    # Attendre que les deux se terminent
    flask_proc.wait()
    esp_proc.wait()
except KeyboardInterrupt:
    print("\nArrêt des deux processus...")
    flask_proc.send_signal(signal.SIGINT)
    esp_proc.send_signal(signal.SIGINT)