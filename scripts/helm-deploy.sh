helm upgrade --install my-app ./helm/my-app \
  --namespace $ENVIRONMENT \
  --values helm/my-app/values-$ENVIRONMENT.yaml \
  --atomic \
  --timeout 5m

