from flask import Flask
from flask_cors import CORS
from config import SECRET_KEY
from routes.auth_routes import bp as auth_bp
from routes.extraction_routes import bp as extraction_bp




app = Flask(__name__)

app.config["SECRET_KEY"] = SECRET_KEY
app.register_blueprint(extraction_bp)
CORS(app)

app.register_blueprint(auth_bp)



@app.route("/")
def home():
    return {"message": "Backend extraction venin fonctionne"}


if __name__ == "__main__":
    app.run(debug=True)