#!/bin/bash

# Build and Deploy Script for JD Services Platform
set -e

ENVIRONMENT=${1:-dev}
BUILD_ID=${2:-latest}

echo "Building and deploying JD Services Platform to environment: $ENVIRONMENT"

# Set environment-specific variables
case $ENVIRONMENT in
  "dev")
    RESOURCE_GROUP="jd-svc-platform-dev-rg"
    ACR_NAME="jdsvcplatformdevacr"
    AKS_NAME="jd-svc-platform-dev-aks"
    ;;
  "staging")
    RESOURCE_GROUP="jd-svc-platform-staging-rg"
    ACR_NAME="jdsvcplatformstagingacr"
    AKS_NAME="jd-svc-platform-staging-aks"
    ;;
  "prod")
    RESOURCE_GROUP="jd-svc-platform-prod-rg"
    ACR_NAME="jdsvcplatformprodacr"
    AKS_NAME="jd-svc-platform-prod-aks"
    ;;
  *)
    echo "Invalid environment: $ENVIRONMENT"
    exit 1
    ;;
esac

echo "Environment variables set for: $ENVIRONMENT"

# Login to Azure and ACR
echo "Logging in to Azure..."
az login --identity 2>/dev/null || echo "Using existing Azure login"

echo "Getting ACR credentials..."
az acr login --name $ACR_NAME

# Get AKS credentials
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

# Build and push Docker images
echo "Building and pushing Docker images..."

# Orders Service
echo "Building Orders Service..."
cd services/orders-service
docker build -t $ACR_NAME.azurecr.io/orders-service:$BUILD_ID .
docker build -t $ACR_NAME.azurecr.io/orders-service:latest .
docker push $ACR_NAME.azurecr.io/orders-service:$BUILD_ID
docker push $ACR_NAME.azurecr.io/orders-service:latest
cd ../..

# Inventory Service
echo "Building Inventory Service..."
cd services/inventory-service
docker build -t $ACR_NAME.azurecr.io/inventory-service:$BUILD_ID .
docker build -t $ACR_NAME.azurecr.io/inventory-service:latest .
docker push $ACR_NAME.azurecr.io/inventory-service:$BUILD_ID
docker push $ACR_NAME.azurecr.io/inventory-service:latest
cd ../..

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."

# Apply configuration
kubectl apply -f k8s/config.yaml

# Deploy services
kubectl apply -f k8s/orders-service.yaml
kubectl apply -f k8s/inventory-service.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/orders-service --timeout=300s
kubectl rollout status deployment/inventory-service --timeout=300s

echo "Deployment completed successfully!"

# Show deployment status
echo "Current deployment status:"
kubectl get pods -l app=orders-service
kubectl get pods -l app=inventory-service
kubectl get services

echo "Services endpoints:"
kubectl get ingress