# Architecture Guide

## Overview

The JD Services Platform implements a microservices architecture deployed on Azure Kubernetes Service (AKS), providing a scalable and maintainable solution for orders management.

## Architecture Components

### Core Services

1. **Orders Service**
   - Manages order lifecycle
   - Orchestrates order processing
   - Publishes order events
   - Port: 8080

2. **Inventory Service**
   - Manages product inventory
   - Handles stock reservations
   - Tracks product availability
   - Port: 8080

3. **Payment Service** *(Planned)*
   - Processes payments
   - Validates payment methods
   - Handles payment events
   - Port: 8080

4. **User Service** *(Planned)*
   - Manages user authentication
   - Handles user profiles
   - Provides authorization
   - Port: 8080

5. **Notification Service** *(Planned)*
   - Sends notifications
   - Manages notification preferences
   - Handles email/SMS delivery
   - Port: 8080

### Infrastructure Components

#### Azure Resources

- **Azure Kubernetes Service (AKS)**: Container orchestration platform
- **Azure Container Registry (ACR)**: Private container registry
- **Azure SQL Database**: Relational database for each service
- **Azure Service Bus**: Message broker for event-driven communication
- **Azure Key Vault**: Secrets and certificate management
- **Azure Application Insights**: Application performance monitoring
- **Azure Log Analytics**: Centralized logging

#### Databases

Each service has its own dedicated database to ensure data isolation:

- `orders` database - Orders Service
- `inventory` database - Inventory Service  
- `users` database - User Service
- `payments` database - Payment Service

#### Messaging

Azure Service Bus provides asynchronous messaging between services:

- `order-events` topic - Order lifecycle events
- `inventory-events` topic - Inventory changes
- `payment-events` topic - Payment processing events
- `notification-events` topic - Notification triggers

## Data Flow

1. **Order Creation**:
   ```
   Client → Orders API → Orders Service → Service Bus (order-events) 
   → Inventory Service (stock reservation) → Payment Service (payment processing)
   ```

2. **Stock Management**:
   ```
   Inventory API → Inventory Service → Service Bus (inventory-events)
   → Orders Service (stock updates)
   ```

3. **Notifications**:
   ```
   Service Events → Service Bus → Notification Service 
   → External Services (Email/SMS providers)
   ```

## Security

- **Authentication**: Azure AD integration (planned)
- **Authorization**: JWT tokens with role-based access
- **Secrets Management**: Azure Key Vault for sensitive configuration
- **Network Security**: Private endpoints and network policies
- **Transport Security**: TLS/HTTPS for all communications

## Monitoring and Observability

- **Application Insights**: Performance metrics, dependency tracking
- **Structured Logging**: Serilog with JSON formatting
- **Health Checks**: Built-in health endpoints for each service
- **Distributed Tracing**: Correlation IDs across service calls

## Deployment Architecture

```
Internet Gateway
       ↓
   Load Balancer
       ↓
   Ingress Controller (NGINX)
       ↓
┌─────────────────────────────────────┐
│            AKS Cluster              │
│  ┌─────────────┐ ┌─────────────┐   │
│  │   Orders    │ │ Inventory   │   │
│  │   Service   │ │  Service    │   │
│  │   (Pods)    │ │   (Pods)    │   │
│  └─────────────┘ └─────────────┘   │
└─────────────────────────────────────┘
       ↓                 ↓
┌─────────────┐   ┌─────────────┐
│ Azure SQL   │   │ Service Bus │
│ Databases   │   │  Topics     │
└─────────────┘   └─────────────┘
```

## Scalability

- **Horizontal Scaling**: Multiple pod replicas per service
- **Auto-scaling**: HPA based on CPU/memory metrics
- **Database Scaling**: Azure SQL elastic pools
- **Caching**: Redis cache for frequently accessed data (planned)

## Resilience Patterns

- **Circuit Breaker**: Prevent cascade failures
- **Retry Logic**: Exponential backoff for transient failures
- **Bulkhead**: Resource isolation between services
- **Health Checks**: Kubernetes liveness/readiness probes
- **Graceful Degradation**: Fallback mechanisms for service dependencies