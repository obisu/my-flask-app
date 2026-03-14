#!/bin/bash

echo "----------------------------------------"
echo "🚀 Frontend Build + Docker + K8s Deploy"
echo "----------------------------------------"

# Ask for version tag
read -p "Enter new version tag (e.g., v12): " TAG

if [ -z "$TAG" ]; then
  echo "❌ No tag provided. Exiting."
  exit 1
fi

IMAGE="obisu/my-frontend:$TAG"

echo "🔧 Running React production build..."
npm run build || { echo "❌ Build failed"; exit 1; }

echo "🐳 Building Docker image: $IMAGE"
docker build -t $IMAGE . || { echo "❌ Docker build failed"; exit 1; }

echo "📤 Pushing Docker image..."
docker push $IMAGE || { echo "❌ Docker push failed"; exit 1; }

echo "📝 Updating Kubernetes deployment..."
sed -i "s|image: obisu/my-frontend:.*|image: $IMAGE|" frontend-deployment.yaml

echo "☸️ Applying Kubernetes changes..."
kubectl apply -f frontend-deployment.yaml

echo "🔄 Restarting deployment..."
kubectl rollout restart deployment frontend-deployment

echo "----------------------------------------"
echo "🎉 Deployment complete! Running version: $TAG"
echo "----------------------------------------"

