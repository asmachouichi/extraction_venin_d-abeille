from flask import Flask, request, jsonify
import mysql.connector
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Connexion à la base de données
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="extraction_venin"
)

# Route test
@app.route('/', methods=['GET'])
def home():
    return "Serveur Flask fonctionne !"

# Route signup
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    cursor = db.cursor()
    sql = "INSERT INTO users (full_name, email, password) VALUES (%s, %s, %s)"
    values = (data["full_name"], data["email"], data["password"])
    cursor.execute(sql, values)
    db.commit()
    cursor.close()
    return jsonify({"message": "User registered successfully"}), 201

# Route login
@app.route('/signin', methods=['POST'])
def login():
    try:
        data = request.json
        email = data["email"]
        password = data["password"]

        cursor = db.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM users WHERE email=%s AND password=%s", 
            (email, password)
        )
        user = cursor.fetchone()
        cursor.close()

        if user:
            return jsonify({
                "message": "Login successful",
                "user_id": user["id"],
                "full_name": user["full_name"],
                "email": user["email"],
                "role": user.get("role", "user")  # si tu ajoutes colonne role
            }), 200
        else:
            return jsonify({"message": "Invalid email or password"}), 401

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Lancer le serveur Flask
if __name__ == '__main__':
    app.run(debug=True)