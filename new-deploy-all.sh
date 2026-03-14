#!/bin/bash

set -euo pipefail

echo "----------------------------------------"
echo "🚀 FULL STACK DEPLOY TOOL"
echo "----------------------------------------"

# Validate argument
if [[ -z "${1:-}" ]]; then
  echo "Usage:"
  echo "  ./deploy-all.sh frontend"
  echo "  ./deploy-all.sh backend"
  echo "  ./deploy-all.sh all"
  exit 1
fi

TARGET=$1

############################################
# DETERMINE SCRIPT LOCATION
############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"

echo "📁 Script directory: $SCRIPT_DIR"
echo "📁 Project root: $PROJECT_ROOT"

############################################
# AUTO VERSION TAG
############################################
TAG="v$(date +%Y%m%d-%H%M)"
echo "🔖 Using version tag: $TAG"

############################################
# HELPER: WAIT FOR POD READY
############################################
wait_for_pod_ready() {
  local label_selector=$1
  local app_name=$2
  local max_attempts=30

  echo "⏳ Waiting for $app_name pod to become Ready..."

  for i in $(seq 1 $max_attempts); do
    POD=$(kubectl get pod -l "$label_selector" \
      --sort-by=.metadata.creationTimestamp \
      -o jsonpath="{.items[-1].metadata.name}" 2>/dev/null || true)

    if [[ -z "${POD:-}" ]]; then
      echo "⏳ No $app_name pod found yet... retrying ($i/$max_attempts)"
      sleep 2
      continue
    fi

    PHASE=$(kubectl get pod "$POD" -o jsonpath="{.status.phase}" 2>/dev/null || true)

    if [[ "$PHASE" != "Running" ]]; then
      echo "⏳ Newest $app_name pod ($POD) phase is '$PHASE' (waiting for Running)... ($i/$max_attempts)"
      sleep 2
      continue
    fi

    READY=$(kubectl get pod "$POD" \
      -o jsonpath="{.status.containerStatuses[0].ready}" 2>/dev/null || true)

    if [[ "$READY" == "true" ]]; then
      echo "✅ $app_name pod is Ready: $POD"
      echo "📌 $app_name pod status:"
      kubectl get pod "$POD" -o wide
      return 0
    fi

    echo "⏳ Newest $app_name pod ($POD) is Running but not Ready yet... retrying ($i/$max_attempts)"
    sleep 2
  done

  echo "❌ $app_name pod did not become Ready in time"
  exit 1
}

############################################
# FRONTEND DEPLOY FUNCTION
############################################
deploy_frontend() {
  echo ""
  echo "=== 🌐 FRONTEND DEPLOY ==="

  cd "$FRONTEND_DIR" || { echo "❌ Frontend folder not found"; exit 1; }

  echo "📦 Building React app..."
  npm run build || { echo "❌ Frontend build failed"; exit 1; }

  FRONTEND_IMAGE="obisu/my-frontend:$TAG"

  echo "🐳 Building Docker image: $FRONTEND_IMAGE"
  docker build -t "$FRONTEND_IMAGE" . || { echo "❌ Docker build failed"; exit 1; }

  echo "📤 Pushing image..."
  docker push "$FRONTEND_IMAGE" || { echo "❌ Docker push failed"; exit 1; }

  echo "📝 Updating frontend deployment YAML..."
  sed -i "s|image: obisu/my-frontend:.*|image: $FRONTEND_IMAGE|" "$FRONTEND_DIR/frontend-deployment.yaml"

  echo "☸️ Applying frontend changes..."
  kubectl apply -f "$FRONTEND_DIR/frontend-deployment.yaml"

  echo "🔄 Restarting frontend deployment..."
  kubectl rollout restart deployment frontend-deployment

  wait_for_pod_ready "app=frontend" "Frontend"
}

############################################
# BACKEND DEPLOY FUNCTION
############################################
deploy_backend() {
  echo ""
  echo "=== 🐍 BACKEND DEPLOY ==="

  cd "$BACKEND_DIR" || { echo "❌ Backend folder not found"; exit 1; }

  BACKEND_IMAGE="obisu/my-backend:$TAG"

  echo "🐳 Building Docker image: $BACKEND_IMAGE"
  docker build -t "$BACKEND_IMAGE" . || { echo "❌ Docker build failed"; exit 1; }

  echo "📤 Pushing image..."
  docker push "$BACKEND_IMAGE" || { echo "❌ Docker push failed"; exit 1; }

  echo "📝 Updating backend deployment YAML..."
  sed -i "s|image: obisu/my-backend:.*|image: $BACKEND_IMAGE|" "$BACKEND_DIR/backend-deployment.yaml"

  echo "☸️ Applying backend changes..."
  kubectl apply -f "$BACKEND_DIR/backend-deployment.yaml"

  echo "🔄 Restarting backend deployment..."
  kubectl rollout restart deployment flask-backend

  wait_for_pod_ready "app=flask-backend" "Backend"

  echo "🌐 Checking backend health endpoint..."
  kubectl exec -it "$POD" -- curl -s http://localhost:5000/api/health || echo "⚠️ Health check failed"
}

############################################
# EXECUTE BASED ON ARGUMENT
############################################

case $TARGET in
  frontend)
    deploy_frontend
    ;;
  backend)
    deploy_backend
    ;;
  all)
    deploy_frontend
    deploy_backend
    ;;
  *)
    echo "❌ Invalid option: $TARGET"
    echo "Valid options: frontend, backend, all"
    exit 1
    ;;
esac

echo ""
echo "----------------------------------------"
echo "🎉 DEPLOY COMPLETE — Version: $TAG"
echo "----------------------------------------"

