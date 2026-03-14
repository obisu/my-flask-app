#!/bin/bash

echo "----------------------------------------"
echo "🚀 FULL STACK DEPLOY TOOL"
echo "----------------------------------------"

# Validate argument
if [[ -z "$1" ]]; then
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

# Resolve the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project root is the script directory
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
  docker build -t $FRONTEND_IMAGE . || { echo "❌ Docker build failed"; exit 1; }

  echo "📤 Pushing image..."
  docker push $FRONTEND_IMAGE || { echo "❌ Docker push failed"; exit 1; }

  echo "📝 Updating frontend deployment YAML..."
  sed -i "s|image: obisu/my-frontend:.*|image: $FRONTEND_IMAGE|" "$FRONTEND_DIR/frontend-deployment.yaml"

  echo "☸️ Applying frontend changes..."
  kubectl apply -f "$FRONTEND_DIR/frontend-deployment.yaml"

  echo "🔄 Restarting frontend deployment..."
  kubectl rollout restart deployment frontend-deployment

  echo "⏳ Waiting for frontend pod to become Ready..."

  # Wait for newest pod to reach Ready state (max 60 seconds)
  for i in {1..30}; do

    # 1️⃣ Always select the newest pod by creation timestamp
    POD=$(kubectl get pod -l app=frontend \
      --sort-by=.metadata.creationTimestamp \
      -o jsonpath="{.items[-1].metadata.name}" 2>/dev/null)

    if [[ -z "$POD" ]]; then
      echo "⏳ No pod found yet... retrying ($i/30)"
      sleep 2
      continue
    fi

    # 2️⃣ Check that this newest pod is in Running phase
    PHASE=$(kubectl get pod "$POD" -o jsonpath="{.status.phase}" 2>/dev/null)

    if [[ "$PHASE" != "Running" ]]; then
      echo "⏳ Newest pod ($POD) phase is '$PHASE' (waiting for Running)... ($i/30)"
      sleep 2
      continue
    fi

    # 3️⃣ Check if that same pod is Ready
    READY=$(kubectl get pod "$POD" \
      -o jsonpath="{.status.containerStatuses[0].ready}" 2>/dev/null)

    if [[ "$READY" == "true" ]]; then
      echo "✅ Frontend pod is Ready: $POD"
      break
    fi

    echo "⏳ Newest pod ($POD) is Running but not Ready yet... retrying ($i/30)"
    sleep 2
  done

  echo "📌 Frontend pod status:"
  kubectl get pods -l app=frontend -o wide
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
  docker build -t $BACKEND_IMAGE . || { echo "❌ Docker build failed"; exit 1; }

  echo "📤 Pushing image..."
  docker push $BACKEND_IMAGE || { echo "❌ Docker push failed"; exit 1; }

  echo "📝 Updating backend deployment YAML..."
  sed -i "s|image: obisu/my-backend:.*|image: $BACKEND_IMAGE|" "$BACKEND_DIR/backend-deployment.yaml"

  echo "☸️ Applying backend changes..."
  kubectl apply -f "$BACKEND_DIR/backend-deployment.yaml"

  echo "🔄 Restarting backend deployment..."
  kubectl rollout restart deployment flask-backend

  echo "⏳ Waiting for backend pod to become Ready..."

  # Wait for newest pod to reach Ready state (max 60 seconds)
  for i in {1..30}; do

    # 1️⃣ Always select the newest pod by creation timestamp
    POD=$(kubectl get pod -l app=flask-backend \
      --sort-by=.metadata.creationTimestamp \
      -o jsonpath="{.items[-1].metadata.name}" 2>/dev/null)

    if [[ -z "$POD" ]]; then
      echo "⏳ No pod found yet... retrying ($i/30)"
      sleep 2
      continue
    fi

    # 2️⃣ Check that this newest pod is in Running phase
    PHASE=$(kubectl get pod "$POD" -o jsonpath="{.status.phase}" 2>/dev/null)

    if [[ "$PHASE" != "Running" ]]; then
      echo "⏳ Newest pod ($POD) phase is '$PHASE' (waiting for Running)... ($i/30)"
      sleep 2
      continue
    fi

    # 3️⃣ Check if that same pod is Ready
    READY=$(kubectl get pod "$POD" \
      -o jsonpath="{.status.containerStatuses[0].ready}" 2>/dev/null)

    if [[ "$READY" == "true" ]]; then
      echo "✅ Backend pod is Ready: $POD"
      break
    fi

    echo "⏳ Newest pod ($POD) is Running but not Ready yet... retrying ($i/30)"
    sleep 2
  done

  echo "📌 Backend pod status:"
  kubectl get pods -l app=flask-backend -o wide

  echo "🌐 Checking backend health endpoint..."
  kubectl exec -it "$POD" -- curl -s http://localhost:5000/api/health
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

