# JD Services Platform

A microservices architecture for orders management, deployed on Azure using Terraform.

## Architecture Overview

This platform implements a microservices architecture with the following core services:

- **Orders Service**: Main order management and orchestration
- **Inventory Service**: Product inventory management
- **Payment Service**: Payment processing and validation
- **User Service**: User authentication and profile management  
- **Notification Service**: Order status and event notifications

## Infrastructure

The platform is deployed on Azure using:

- **Azure Kubernetes Service (AKS)** for container orchestration
- **Azure Container Registry (ACR)** for container images
- **Azure SQL Database** for transactional data
- **Azure Service Bus** for messaging
- **Azure Application Insights** for monitoring
- **Terraform** for infrastructure as code

## Directory Structure

```
├── infrastructure/          # Terraform configurations
│   ├── modules/            # Reusable Terraform modules
│   ├── environments/       # Environment-specific configurations
│   └── scripts/           # Deployment scripts
├── services/              # Microservices
│   ├── orders-service/    # Orders management service
│   ├── inventory-service/ # Inventory management service  
│   ├── payment-service/   # Payment processing service
│   ├── user-service/      # User management service
│   └── notification-service/ # Notification service
├── k8s/                   # Kubernetes manifests
├── docs/                  # Documentation
└── scripts/              # Build and deployment scripts
```

## Getting Started

### Prerequisites

- Azure CLI
- Terraform >= 1.0
- Docker
- kubectl
- Helm

### Deployment

1. **Infrastructure Setup**:
   ```bash
   cd infrastructure/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

2. **Services Deployment**:
   ```bash
   ./scripts/build-and-deploy.sh dev
   ```

3. **Access the Platform**:
   - API Gateway: `https://api-gateway-{env}.azurewebsites.net`
   - Monitoring: Azure Portal > Application Insights

## Development

Each service follows a standard structure with:
- Docker containerization
- Health checks and readiness probes
- Structured logging
- Configuration management
- Unit and integration tests

## Documentation

- [Architecture Guide](docs/architecture.md)
- [API Documentation](docs/api.md)
- [Deployment Guide](docs/deployment.md)
- [Development Guide](docs/development.md)
