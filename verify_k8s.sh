#!/bin/bash

echo "========================================"
echo "KUBERNETES FULL STACK STATUS CHECK"
echo "========================================"

echo ""
echo "🔹 Pods:"
kubectl get pods -o wide

echo ""
echo "🔹 Services:"
kubectl get svc

echo ""
echo "🔹 Deployments:"
kubectl get deployments

echo ""
echo "🔹 Ingress:"
kubectl get ingress

echo ""
echo "🔹 Docker Images (local):"
docker images | grep -E "my-frontend|my-backend|flask|frontend"

echo ""
echo "🔹 Testing Ingress Frontend (http://localhost):"
curl -I http://localhost 2>/dev/null | head -n 1

echo ""
echo "🔹 Testing Backend via Ingress (http://localhost/flask/status):"
curl -s http://localhost/flask/status || echo "Backend endpoint unreachable"

echo ""
echo "========================================"
echo "STATUS CHECK COMPLETE"
echo "========================================"
