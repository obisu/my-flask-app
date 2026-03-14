#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo -e "\n=============================="
echo -e "   FULL K8S STACK VALIDATION"
echo -e "==============================\n"

###############################################
# 1. Backend Deployment
###############################################
echo -e "1. Checking Backend Deployment..."
kubectl get deploy flask-backend >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Backend Deployment exists${NC}"
else
    echo -e "   ${RED}✘ Backend Deployment NOT found${NC}"
fi

###############################################
# 2. Backend Pod
###############################################
echo -e "\n2. Checking Backend Pod..."
BACKEND_POD=$(kubectl get pods -l app=flask-backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$BACKEND_POD" ]; then
    STATUS=$(kubectl get pod "$BACKEND_POD" -o jsonpath='{.status.phase}')
    echo -e "   Pod: $BACKEND_POD"
    if [ "$STATUS" == "Running" ]; then
        echo -e "   ${GREEN}✔ Backend Pod is Running${NC}"
    else
        echo -e "   ${RED}✘ Backend Pod is NOT running ($STATUS)${NC}"
    fi
else
    echo -e "   ${RED}✘ No backend pod found${NC}"
fi

###############################################
# 3. Backend Service
###############################################
echo -e "\n3. Checking Backend Service..."
kubectl get svc flask-backend >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Backend Service exists${NC}"
else
    echo -e "   ${RED}✘ Backend Service NOT found${NC}"
fi

echo -e "   Checking backend service endpoints..."
kubectl get endpoints flask-backend | grep 5000 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Backend Service has active endpoints${NC}"
else
    echo -e "   ${RED}✘ Backend Service has NO endpoints${NC}"
fi

###############################################
# 4. Frontend Deployment
###############################################
echo -e "\n4. Checking Frontend Deployment..."
kubectl get deploy frontend-deployment >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Frontend Deployment exists${NC}"
else
    echo -e "   ${RED}✘ Frontend Deployment NOT found${NC}"
fi

###############################################
# 5. Frontend Pod
###############################################
echo -e "\n5. Checking Frontend Pod..."
FRONTEND_POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$FRONTEND_POD" ]; then
    STATUS=$(kubectl get pod "$FRONTEND_POD" -o jsonpath='{.status.phase}')
    echo -e "   Pod: $FRONTEND_POD"
    if [ "$STATUS" == "Running" ]; then
        echo -e "   ${GREEN}✔ Frontend Pod is Running${NC}"
    else
        echo -e "   ${RED}✘ Frontend Pod is NOT running ($STATUS)${NC}"
    fi
else
    echo -e "   ${RED}✘ No frontend pod found${NC}"
fi

###############################################
# 6. Frontend Service
###############################################
echo -e "\n6. Checking Frontend Service..."
kubectl get svc frontend-service >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Frontend Service exists${NC}"
else
    echo -e "   ${RED}✘ Frontend Service NOT found${NC}"
fi

###############################################
# 7. Ingress
###############################################
echo -e "\n7. Checking Ingress..."
kubectl get ingress my-ingress >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✔ Ingress exists${NC}"
else
    echo -e "   ${RED}✘ Ingress NOT found${NC}"
fi

###############################################
# 8. Test Frontend via Ingress
###############################################
echo -e "\n8. Testing Frontend via Ingress..."
FRONTEND_STATUS=$(curl -I http://localhost 2>/dev/null | head -n 1)

if [[ "$FRONTEND_STATUS" == *"200"* ]]; then
    echo -e "   ${GREEN}✔ Frontend reachable via Ingress${NC}"
else
    echo -e "   ${RED}✘ Frontend NOT reachable via Ingress${NC}"
fi

###############################################
# 9. Test Backend via Ingress
###############################################
echo -e "\n9. Testing Backend via Ingress..."
BACKEND_RESPONSE=$(curl -s http://localhost/flask/health)

if [[ "$BACKEND_RESPONSE" == *"message"* ]]; then
    echo -e "   ${GREEN}✔ Backend reachable via Ingress${NC}"
    echo -e "   Response: $BACKEND_RESPONSE"
else
    echo -e "   ${RED}✘ Backend NOT reachable via Ingress${NC}"
    echo -e "   Response: $BACKEND_RESPONSE"
fi

echo -e "\n=============================="
echo -e "   FULL STACK VALIDATION DONE"
echo -e "==============================\n"
