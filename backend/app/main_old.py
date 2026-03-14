from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/api/users", methods=["GET"])
def get_users():
    users = [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"},
        {"id": 3, "name": "Charlie"}
    ]
    return jsonify(users), 200

@app.route("/api/login", methods=["POST"])
def login():
    data = request.get_json()

    if not data or "username" not in data or "password" not in data:
        return jsonify({"error": "Missing username or password"}), 400

    if data["username"] == "admin" and data["password"] == "secret":
        return jsonify({"message": "Backend is alive"

    return jsonify({"message": "Backend is alive"

@app.route("/api/data", methods=["GET"])
def get_data():
    sample_data = {
        "temperature": 22.5,
        "humidity": 60,
        "status": "stable"
    }
    return jsonify(sample_data), 200

@app.route("/")
def index():
    return jsonify({"message": "Backend is alive"
