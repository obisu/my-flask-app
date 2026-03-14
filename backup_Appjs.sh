#!/bin/bash

APP_FILE="frontend/src/App.js"

if [ ! -f "$APP_FILE" ]; then
  echo "❌ App.js not found at $APP_FILE"
  exit 1
fi

# Create backups directory if missing
BACKUP_DIR="frontend/src/backups"
mkdir -p "$BACKUP_DIR"

# Timestamp for unique backup names
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

BACKUP_FILE="$BACKUP_DIR/App.js.$TIMESTAMP.bak"

# Only create backup if file doesn't already exist
if [ -f "$BACKUP_FILE" ]; then
  echo "✔ Backup already exists: $BACKUP_FILE"
else
  echo "➕ Creating backup: $BACKUP_FILE"
  cp "$APP_FILE" "$BACKUP_FILE"
fi

echo "Done."

