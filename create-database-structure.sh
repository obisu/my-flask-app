#!/bin/bash

echo "----------------------------------------"
echo "📁 Setting up database directory structure"
echo "----------------------------------------"

DB_DIR="database"
K8S_DIR="$DB_DIR/k8s"
INIT_DIR="$DB_DIR/init"

# Create directories safely
mkdir -p "$K8S_DIR"
mkdir -p "$INIT_DIR"

echo "📁 Ensured directories exist:"
echo "   - $DB_DIR/"
echo "   - $K8S_DIR/"
echo "   - $INIT_DIR/"

# Function to safely create a file if missing
create_if_missing() {
  local file="$1"
  local content="$2"

  if [ -f "$file" ]; then
    echo "⚠️  Skipped (already exists): $file"
  else
    echo "$content" > "$file"
    echo "🆕 Created: $file"
  fi
}

# Placeholder YAML files
create_if_missing "$K8S_DIR/postgres-secret.yaml" "# PostgreSQL Secret YAML"
create_if_missing "$K8S_DIR/postgres-pvc.yaml" "# PostgreSQL PVC YAML"
create_if_missing "$K8S_DIR/postgres-statefulset.yaml" "# PostgreSQL StatefulSet YAML"
create_if_missing "$K8S_DIR/postgres-service.yaml" "# PostgreSQL Service YAML"

# init.sql
create_if_missing "$INIT_DIR/init.sql" "-- SQL initialization script"

# README
create_if_missing "$DB_DIR/README.md" "# Database Setup Documentation"

echo "----------------------------------------"
echo "🎉 Database directory structure ready!"
echo "----------------------------------------"

