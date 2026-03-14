#!/bin/bash

echo "----------------------------------------"
echo "🚀 Backend Build + Docker + K8s Deploy"
echo "----------------------------------------"

# Ask for version tag
read -p "Enter new backend version tag (e.g., v5): " TAG

if [ -z "$TAG" ]; then
  echo "❌ No tag provided. Exiting."
  exit 1
fi

IMAGE="obisu/my-backend:$TAG"

echo "🐳 Building Docker image: $IMAGE"
docker build -t $IMAGE . || { echo "❌ Docker build failed"; exit 1; }

echo "📤 Pushing Docker image..."
docker push $IMAGE || { echo "❌ Docker push failed"; exit 1; }

echo "📝 Updating Kubernetes deployment..."
sed -i "s|image: obisu/my-backend:.*|image: $IMAGE|" backend-deployment.yaml

echo "☸️ Applying Kubernetes changes..."
kubectl apply -f backend-deployment.yaml

echo "🔄 Restarting backend deployment..."
kubectl rollout restart deployment flask-backend

echo "----------------------------------------"
echo "🎉 Backend deployment complete! Running version: $TAG"
echo "----------------------------------------"

