from flask import Flask, jsonify
from flask_cors import CORS
from config import SECRET_KEY
from routes.auth_routes import bp as auth_bp
from routes.extraction_routes import bp as extraction_bp

app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY

# Activer CORS
CORS(app)

# Enregistrer les blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(extraction_bp)

# Exemple de données simulées pour le dashboard
DATA = [
    {"jour": 1, "quantite": 5.0, "duree": 12, "date": "10/03/2026"},
    {"jour": 2, "quantite": 7.2, "duree": 15, "date": "11/03/2026"},
    {"jour": 3, "quantite": 6.5, "duree": 10, "date": "12/03/2026"},
    {"jour": 4, "quantite": 4.8, "duree": 13, "date": "13/03/2026"},
    {"jour": 5, "quantite": 9.0, "duree": 14, "date": "14/03/2026"},
    {"jour": 6, "quantite": 3.5, "duree": 11, "date": "15/03/2026"},
    {"jour": 7, "quantite": 6.0, "duree": 12, "date": "16/03/2026"},
]

@app.route("/")
def home():
    return {"message": "Backend extraction venin fonctionne"}

@app.route("/stats/venin", methods=["GET"])
def stats_venin():
    return jsonify(DATA)

if __name__ == "__main__":
    # Ne garder qu'un seul app.run
    app.run(host="0.0.0.0", port=5000, debug=True)