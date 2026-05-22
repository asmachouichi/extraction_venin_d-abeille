from flask import Flask
from flask_cors import CORS
from flask_bcrypt import Bcrypt

from config import *
from extensions import mysql, jwt


# ================= APP INIT =================
app = Flask(__name__)

# ================= CONFIG =================
app.config["SECRET_KEY"] = SECRET_KEY
app.config["JWT_SECRET_KEY"] = JWT_SECRET_KEY

app.config["MYSQL_HOST"] = MYSQL_HOST
app.config["MYSQL_USER"] = MYSQL_USER
app.config["MYSQL_PASSWORD"] = MYSQL_PASSWORD
app.config["MYSQL_DB"] = MYSQL_DB

# ================= EXTENSIONS INIT =================
mysql.init_app(app)
jwt.init_app(app)
bcrypt = Bcrypt(app)
CORS(app)

# ================= ROUTES =================
from routes.auth_routes import bp as auth_bp
from routes.sensor_routes import bp as sensor_bp
from routes.control_routes import bp as control_bp

app.register_blueprint(auth_bp)
app.register_blueprint(sensor_bp, url_prefix="/sensors")
app.register_blueprint(control_bp, url_prefix="/control")

# ================= AUTO ADMIN CREATION =================
def create_admin():
    with app.app_context():
        cur = mysql.connection.cursor()

        cur.execute(
            "SELECT id FROM users WHERE email=%s",
            ("admin@gmail.com",)
        )

        admin = cur.fetchone()

        if not admin:

            hashed_pw = bcrypt.generate_password_hash(
                "admin123"
            ).decode("utf-8")

            cur.execute("""
                INSERT INTO users (username, email, password, role)
                VALUES (%s, %s, %s, %s)
            """, (
                "admin",
                "admin@gmail.com",
                hashed_pw,
                "admin"
            ))

            mysql.connection.commit()
            print("✅ Default admin created!")

        else:
            print("✅ Admin already exists")

        cur.close()

# ================= ROUTES TEST =================
@app.route("/")
def home():
    return {
        "message": "Flask + MySQL + Sensors API Running 🚀"
    }

# ================= MAIN =================
if __name__ == "__main__":
    create_admin()
    app.run(host="0.0.0.0", port=5000, debug=True)