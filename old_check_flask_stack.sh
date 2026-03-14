#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo -e "\n=============================="
echo -e "  FLASK K8S STACK VALIDATION"
echo -e "==============================\n"

### 1. Verify Deployment ###
echo -e "1. Checking Deployment..."
kubectl get deploy flask-backend >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Deployment exists${NC}"
else
    echo -e "   ${RED}✘ Deployment NOT found${NC}"
fi

### 2. Verify Pod Running ###
echo -e "\n2. Checking Pod status..."
POD=$(kubectl get pods -l app=flask-backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD" ]; then
    STATUS=$(kubectl get pod "$POD" -o jsonpath='{.status.phase}')
    echo -e "   Pod: $POD"
    if [ "$STATUS" == "Running" ]; then
        echo -e "   ${GREEN}✔ Pod is Running${NC}"
    else
        echo -e "   ${RED}✘ Pod is NOT running ($STATUS)${NC}"
    fi
else
    echo -e "   ${RED}✘ No pod found for deployment${NC}"
fi

### 3. Verify Gunicorn Running (via /proc/1/cmdline) ###
echo -e "\n3. Checking Gunicorn process inside pod..."

GUNICORN_PROC=$(kubectl exec "$POD" -- sh -c "tr '\0' ' ' < /proc/1/cmdline | grep -i gunicorn")

if [[ -n "$GUNICORN_PROC" ]]; then
    echo -e "   ${GREEN}✔ Gunicorn is running${NC}"
else
    echo -e "   ${RED}✘ Gunicorn NOT running${NC}"
fi

### 4. Verify Service ###
echo -e "\n4. Checking Service..."
kubectl get svc flask-backend >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Service exists${NC}"
else
    echo -e "   ${RED}✘ Service NOT found${NC}"
fi

echo -e "   Checking service endpoints..."
kubectl get endpoints flask-backend | grep 5000 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Service has active endpoints${NC}"
else
    echo -e "   ${RED}✘ Service has NO endpoints${NC}"
fi

### 5. Verify Ingress ###
echo -e "\n5. Checking Ingress..."
kubectl get ingress flask-backend-ingress >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Ingress exists${NC}"
else
    echo -e "   ${RED}✘ Ingress NOT found${NC}"
fi

### 6. Verify Ingress Routing ###
echo -e "\n6. Testing external access through Ingress..."
RESPONSE=$(curl -s http://localhost/flask/api/health)

if [[ "$RESPONSE" == *"status"* ]]; then
    echo -e "   ${GREEN}✔ Ingress routing works${NC}"
    echo -e "   Response: $RESPONSE"
else
    echo -e "   ${RED}✘ Ingress routing FAILED${NC}"
    echo -e "   Response: $RESPONSE"
fi

echo -e "\n=============================="
echo -e "  VALIDATION COMPLETE"
echo -e "==============================\n"
