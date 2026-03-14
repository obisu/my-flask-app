from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

# ---------------------------------------------------------
# Load environment variables safely
# ---------------------------------------------------------
# These defaults allow local development and tests to run
# even when Kubernetes secrets are not present.
DB_USER = os.getenv("POSTGRES_USER", "test_user")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "test_password")
DB_NAME = os.getenv("POSTGRES_DB", "test_db")

# Kubernetes secret sometimes contains malformed values like "tcp://..."
# so we sanitize the host to avoid SQLAlchemy crashes.
raw_host = os.getenv("POSTGRES_HOST", "postgres")

# Strip any accidental tcp:// prefix (seen in some K8s setups)
if raw_host.startswith("tcp://"):
    DB_HOST = raw_host.replace("tcp://", "")
elif raw_host.startswith("tcp:"):
    DB_HOST = raw_host.replace("tcp:", "")
else:
    DB_HOST = raw_host

# ---------------------------------------------------------
# Port handling
# ---------------------------------------------------------
# The bak version hardcoded 5432 because it was stable.
# The new version attempted to read POSTGRES_PORT.
# We merge both approaches safely:
#
# - If POSTGRES_PORT exists and is a clean integer, use it.
# - If it's missing or malformed, fall back to 5432.
# ---------------------------------------------------------
raw_port = os.getenv("POSTGRES_PORT", "5432")

try:
    int(raw_port)  # Validate it's a real integer
    DB_PORT = raw_port
except ValueError:
    DB_PORT = "5432"  # Safe fallback

# ---------------------------------------------------------
# Final DATABASE_URL (merged logic)
# ---------------------------------------------------------
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# ---------------------------------------------------------
# SQLAlchemy setup
# ---------------------------------------------------------
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

