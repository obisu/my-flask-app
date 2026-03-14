from flask import Flask, request, jsonify
from app.db import SessionLocal
from app.models import User
from sqlalchemy import text
import time
from datetime import datetime

app = Flask(__name__)

# -----------------------------------------------
# FIX: Automatically close sessions after requests
# -----------------------------------------------
@app.teardown_appcontext
def shutdown_session(exception=None):
    try:
        db = SessionLocal()
        db.close()
    except:
        pass


# -----------------------------
# Health + Status Endpoints
# -----------------------------
@app.route("/ingress/status", methods=["GET"])
def ingress_status():
    return jsonify({"status": "ok"}), 200

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/api/status", methods=["GET"])
def api_status():
    return jsonify({"status": "ok"}), 200

@app.route("/flask/health")
def flask_health():
    return {"message": "Backend is alive"}

@app.route("/")
def index():
    return jsonify({"message": "Backend is alive"}), 200


# -----------------------------
# USERS (Original Sample Endpoint)
# -----------------------------
@app.route("/api/users-sample", methods=["GET"])
def get_users_sample():
    users = [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"},
        {"id": 3, "name": "Charlie"}
    ]
    return jsonify(users), 200


# -----------------------------
# USERS (DB-backed CRUD)
# -----------------------------
@app.route("/api/users", methods=["GET"])
def list_users():
    db = SessionLocal()
    users = db.query(User).all()
    result = [{"id": u.id, "name": u.username} for u in users]
    db.close()
    return jsonify(result), 200


@app.route("/api/users", methods=["POST"])
def create_user():
    data = request.get_json()
    name = data.get("name")

    if not name:
        return jsonify({"error": "Name is required"}), 400

    db = SessionLocal()
    new_user = User(username=name)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    db.close()

    return jsonify({
        "message": "User added",
        "user": {"id": new_user.id, "name": new_user.username}
    }), 201


@app.route("/api/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        db.close()
        return jsonify({"error": "User not found"}), 404

    db.delete(user)
    db.commit()
    db.close()
    return jsonify({"message": "User deleted"}), 200


@app.route("/api/users/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    data = request.get_json()
    new_name = data.get("name")

    if not new_name:
        return jsonify({"error": "Name is required"}), 400

    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        db.close()
        return jsonify({"error": "User not found"}), 404

    user.username = new_name
    db.commit()
    db.refresh(user)
    db.close()

    return jsonify({
        "message": "User updated",
        "user": {"id": user.id, "name": user.username}
    }), 200


# -----------------------------
# LOGIN (simple demo)
# -----------------------------
@app.route("/api/login", methods=["POST"])
def login():
    data = request.get_json()

    if not data or "username" not in data or "password" not in data:
        return jsonify({"error": "Missing username or password"}), 400

    if data["username"] == "admin" and data["password"] == "secret":
        return jsonify({"message": "Login successful"}), 200

    return jsonify({"message": "Invalid credentials"}), 401


# -----------------------------
# SAMPLE DATA ROUTE
# -----------------------------
@app.route("/api/data", methods=["GET"])
def get_data():
    sample_data = {
        "temperature": 22.5,
        "humidity": 60,
        "status": "stable"
    }
    return jsonify(sample_data), 200


# -----------------------------------------------
# FIXED: User Activity Analytics (REAL DATA)
# -----------------------------------------------
@app.route("/api/stats/user-activity", methods=["GET"])
def user_activity():
    try:
        db = SessionLocal()

        sql = text("""
            SELECT 
                to_char(created_at, 'Dy') AS day,
                COUNT(*) AS count,
                EXTRACT(DOW FROM created_at) AS dow
            FROM users
            WHERE created_at IS NOT NULL
            GROUP BY day, dow
            ORDER BY dow;
        """)

        rows = db.execute(sql).fetchall()
        db.close()

        # Always return Mon → Fri in correct order
        activity = {"Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0}

        for day, count, dow in rows:
            # Only Monday (1) through Friday (5)
            if dow in (1, 2, 3, 4, 5):
                activity[day] = count

        return jsonify({"activity": activity})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -----------------------------
# FLASK ENTRYPOINT
# -----------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)


# -----------------------------------------------
# System Health API
# -----------------------------------------------
START_TIME = time.time()

@app.route("/api/stats/system-health", methods=["GET"])
def system_health():
    health = {
        "backend": "online",
        "database": "unknown",
        "db_latency_ms": None,
        "uptime_seconds": int(time.time() - START_TIME),
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "version": "1.0.0"
    }

    try:
        start = time.time()
        session = SessionLocal()
        session.execute(text("SELECT 1"))
        session.close()

        latency = (time.time() - start) * 1000
        health["database"] = "connected"
        health["db_latency_ms"] = round(latency, 2)

    except Exception as e:
        health["database"] = "error"
        health["db_error"] = str(e)

    return jsonify(health)


# -----------------------------------------------
# Dashboard Summary API
# -----------------------------------------------
@app.route("/api/stats/summary", methods=["GET"])
def dashboard_summary():
    summary = {
        "backend_status": "online",
        "frontend_status": "online",
        "database_status": "unknown",
        "total_users": 0,
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }

    try:
        db = SessionLocal()
        summary["total_users"] = db.query(User).count()
        db.close()
    except Exception as e:
        summary["total_users"] = None
        summary["database_status"] = "error"
        summary["db_error"] = str(e)

    try:
        session = SessionLocal()
        session.execute(text("SELECT 1"))
        session.close()
        summary["database_status"] = "connected"
    except Exception as e:
        summary["database_status"] = "error"
        summary["db_error"] = str(e)

    return jsonify(summary)

