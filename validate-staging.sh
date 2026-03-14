#!/bin/bash

set -e

echo "🔧 Switching to staging branch..."
git checkout staging

echo "📝 Creating test commit..."
echo "# staging test $(date)" >> staging-test.txt
git add staging-test.txt
git commit -m "Staging pipeline validation test"

echo "🚀 Pushing to staging..."
git push origin staging

echo "⏳ Waiting 20 seconds for GitHub Actions to start..."
sleep 20

echo "📡 Checking latest GitHub Actions run for staging branch..."
gh run list --branch staging --limit 1

echo "⏳ Waiting 60 seconds for deployment to apply..."
sleep 60

echo "🔍 Checking pods in staging namespace..."
kubectl get pods -n staging

echo "🔍 Checking deployment image tags..."
kubectl get deploy -n staging -o yaml | grep image:

echo "🔍 Checking rollout status for backend..."
kubectl rollout status deploy/my-app-backend -n staging || true

echo "🔍 Checking rollout status for frontend..."
kubectl rollout status deploy/my-app-frontend -n staging || true

echo "🎉 Staging validation completed."

