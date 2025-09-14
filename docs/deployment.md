# Deployment Guide

## Prerequisites

Before deploying the JD Services Platform, ensure you have the following tools installed:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (latest version)
- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) (for additional deployments)

## Azure Setup

### 1. Login to Azure

```bash
az login
az account set --subscription "your-subscription-id"
```

### 2. Create Service Principal (for automated deployments)

```bash
az ad sp create-for-rbac --name "jd-svc-platform-sp" --role="Contributor" --scopes="/subscriptions/your-subscription-id"
```

Save the output for later use in CI/CD pipelines.

## Infrastructure Deployment

### 1. Deploy Infrastructure with Terraform

Navigate to the environment directory:

```bash
cd infrastructure/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Review the deployment plan:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply
```

**Note**: The first run will create all Azure resources. This may take 15-20 minutes.

### 2. Configure kubectl

Get AKS credentials:

```bash
az aks get-credentials --resource-group jd-svc-platform-dev-rg --name jd-svc-platform-dev-aks
```

Verify connection:

```bash
kubectl cluster-info
kubectl get nodes
```

## Application Deployment

### Method 1: Using the Deployment Script (Recommended)

The deployment script automates the entire process:

```bash
./scripts/build-and-deploy.sh dev
```

This script will:
1. Build Docker images for all services
2. Push images to Azure Container Registry
3. Deploy Kubernetes manifests
4. Wait for deployments to be ready

### Method 2: Manual Deployment

#### Step 1: Build and Push Images

Login to ACR:
```bash
az acr login --name jdsvcplatformdevacr
```

Build and push Orders Service:
```bash
cd services/orders-service
docker build -t jdsvcplatformdevacr.azurecr.io/orders-service:latest .
docker push jdsvcplatformdevacr.azurecr.io/orders-service:latest
cd ../..
```

Build and push Inventory Service:
```bash
cd services/inventory-service
docker build -t jdsvcplatformdevacr.azurecr.io/inventory-service:latest .
docker push jdsvcplatformdevacr.azurecr.io/inventory-service:latest
cd ../..
```

#### Step 2: Update Kubernetes Secrets

Before deploying, update the secrets in `k8s/config.yaml` with actual values from Terraform outputs:

```bash
# Get Terraform outputs
cd infrastructure/environments/dev
terraform output -json > ../../../terraform-outputs.json
cd ../../..

# Update connection strings and keys in k8s/config.yaml
# Replace REPLACE_WITH_ACTUAL_* placeholders with real values
```

#### Step 3: Deploy to Kubernetes

```bash
kubectl apply -f k8s/config.yaml
kubectl apply -f k8s/orders-service.yaml
kubectl apply -f k8s/inventory-service.yaml
```

#### Step 4: Verify Deployment

```bash
kubectl get pods
kubectl get services
kubectl get ingress
```

## Environment-Specific Deployments

### Development Environment

```bash
./scripts/build-and-deploy.sh dev
```

### Staging Environment

1. Update Terraform variables in `infrastructure/environments/staging/terraform.tfvars`
2. Deploy infrastructure:
   ```bash
   cd infrastructure/environments/staging
   terraform init
   terraform apply
   ```
3. Deploy applications:
   ```bash
   ./scripts/build-and-deploy.sh staging
   ```

### Production Environment

1. Update Terraform variables in `infrastructure/environments/prod/terraform.tfvars`
2. Deploy infrastructure:
   ```bash
   cd infrastructure/environments/prod
   terraform init
   terraform apply
   ```
3. Deploy applications:
   ```bash
   ./scripts/build-and-deploy.sh prod
   ```

## Post-Deployment Verification

### 1. Check Service Health

```bash
# Get external IP
kubectl get services

# Test health endpoints
curl http://your-external-ip/api/orders/health
curl http://your-external-ip/api/inventory/health
```

### 2. View Logs

```bash
kubectl logs -l app=orders-service
kubectl logs -l app=inventory-service
```

### 3. Monitor with Azure Application Insights

1. Go to Azure Portal
2. Navigate to Application Insights resource
3. View application map and performance metrics

## Troubleshooting

### Common Issues

1. **Pod not starting**:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Database connection issues**:
   - Verify connection strings in secrets
   - Check SQL Server firewall rules
   - Ensure AKS has access to SQL Database

3. **Image pull errors**:
   - Verify ACR permissions
   - Check image names and tags
   - Ensure AKS has pull permissions to ACR

4. **Service Bus connection issues**:
   - Verify Service Bus connection string
   - Check namespace and topic configurations

### Rolling Back Deployments

```bash
kubectl rollout undo deployment/orders-service
kubectl rollout undo deployment/inventory-service
```

## Scaling

### Manual Scaling

```bash
kubectl scale deployment orders-service --replicas=5
kubectl scale deployment inventory-service --replicas=3
```

### Auto-scaling

Apply HPA (Horizontal Pod Autoscaler):

```bash
kubectl autoscale deployment orders-service --cpu-percent=70 --min=2 --max=10
kubectl autoscale deployment inventory-service --cpu-percent=70 --min=2 --max=8
```

## Backup and Recovery

### Database Backups

Azure SQL Database provides automatic backups. For additional protection:

1. Configure automated backups with longer retention
2. Set up geo-redundant storage
3. Test restore procedures regularly

### Configuration Backups

```bash
# Export Kubernetes configurations
kubectl get all,secrets,configmaps -o yaml > k8s-backup.yaml
```

## Monitoring Setup

### Application Insights Alerts

Set up alerts for:
- High error rates
- Slow response times
- Failed requests
- Resource utilization

### Log Analytics Queries

Common queries for monitoring:
```kusto
// Failed requests
requests
| where success == false
| order by timestamp desc

// High response times
requests
| where duration > 5000
| order by timestamp desc
```