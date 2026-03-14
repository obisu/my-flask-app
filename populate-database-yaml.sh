#!/bin/bash

echo "----------------------------------------"
echo "📝 Populating PostgreSQL YAML files"
echo "----------------------------------------"

DB_K8S_DIR="database/k8s"

populate_if_empty() {
  local file="$1"
  local content="$2"

  if [ ! -s "$file" ]; then
    echo "$content" > "$file"
    echo "🆕 Populated: $file"
  else
    echo "⚠️  Skipped (file already has content): $file"
  fi
}

# postgres-secret.yaml
populate_if_empty "$DB_K8S_DIR/postgres-secret.yaml" \
"apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
data:
  POSTGRES_USER: YWRtaW4=        # base64(admin)
  POSTGRES_PASSWORD: c2VjcmV0    # base64(secret)
  POSTGRES_DB: bXlkYg==          # base64(mydb)
"

# postgres-pvc.yaml
populate_if_empty "$DB_K8S_DIR/postgres-pvc.yaml" \
"apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
"

# postgres-statefulset.yaml
populate_if_empty "$DB_K8S_DIR/postgres-statefulset.yaml" \
"apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        envFrom:
        - secretRef:
            name: postgres-secret
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [\"ReadWriteOnce\"]
      resources:
        requests:
          storage: 5Gi
"

# postgres-service.yaml
populate_if_empty "$DB_K8S_DIR/postgres-service.yaml" \
"apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  ports:
    - port: 5432
  selector:
    app: postgres
"

echo "----------------------------------------"
echo "🎉 PostgreSQL YAML population complete!"
echo "----------------------------------------"

