# Development Guide

## Getting Started

### Prerequisites for Local Development

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) or SQL Server in Docker
- [Azure Service Bus Emulator](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-emulator) (optional)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) or [VS Code](https://code.visualstudio.com/)

### Local Development Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/ptoluganti/jd-svc-platform.git
cd jd-svc-platform
```

#### 2. Start Local Dependencies

Using Docker Compose (create `docker-compose.local.yml`):

```yaml
version: '3.8'
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong!Passw0rd
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql
      
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
      
volumes:
  sqlserver_data:
```

Start services:
```bash
docker-compose -f docker-compose.local.yml up -d
```

#### 3. Update Connection Strings

Update `appsettings.Development.json` in each service:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=Orders;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=true;",
    "ServiceBus": "UseDevelopmentStorage=true"
  }
}
```

#### 4. Run Database Migrations

For Orders Service:
```bash
cd services/orders-service
dotnet ef database update
cd ../..
```

For Inventory Service:
```bash
cd services/inventory-service
dotnet ef database update
cd ../..
```

#### 5. Run Services Locally

Each service can be run independently:

**Orders Service**:
```bash
cd services/orders-service
dotnet run
```

**Inventory Service**:
```bash
cd services/inventory-service
dotnet run
```

Services will be available at:
- Orders Service: `https://localhost:7001`
- Inventory Service: `https://localhost:7002`

## Project Structure

```
jd-svc-platform/
├── infrastructure/          # Terraform infrastructure code
│   ├── modules/            # Reusable Terraform modules
│   ├── environments/       # Environment-specific configs
│   └── scripts/           # Infrastructure scripts
├── services/              # Microservices
│   ├── orders-service/    # Orders management service
│   ├── inventory-service/ # Inventory management service
│   ├── payment-service/   # Payment processing (planned)
│   ├── user-service/      # User management (planned)
│   └── notification-service/ # Notifications (planned)
├── k8s/                   # Kubernetes manifests
├── docs/                  # Documentation
└── scripts/              # Build and deployment scripts
```

## Service Architecture

Each service follows a consistent structure:

```
service-name/
├── Controllers/           # API controllers
├── Models/               # Data models and DTOs
├── Services/             # Business logic services
├── Data/                 # Entity Framework context
├── Dockerfile            # Container definition
├── Program.cs            # Application entry point
├── service-name.csproj   # Project file
└── appsettings.json      # Configuration
```

## Development Workflow

### 1. Creating a New Service

Use the existing services as templates:

```bash
# Copy the orders-service structure
cp -r services/orders-service services/new-service

# Update project files
# - Rename .csproj file
# - Update namespace references
# - Update Dockerfile references
```

### 2. Adding New API Endpoints

1. Create/update models in `Models/` folder
2. Add business logic in `Services/` folder
3. Create controller in `Controllers/` folder
4. Update Entity Framework context if needed
5. Write unit tests

Example controller:
```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;

    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }
}
```

### 3. Database Changes

Using Entity Framework migrations:

```bash
# Add migration
dotnet ef migrations add MigrationName

# Update database
dotnet ef database update

# Generate SQL script
dotnet ef migrations script
```

### 4. Adding Event Publishing

Services communicate through events:

```csharp
// In service layer
await _messagePublisher.PublishOrderEventAsync("ProductUpdated", new
{
    ProductId = product.Id,
    Name = product.Name,
    Price = product.Price,
    Timestamp = DateTime.UtcNow
});
```

## Testing

### Unit Testing

Each service should have a corresponding test project:

```bash
# Create test project
dotnet new xunit -n OrdersService.Tests
cd OrdersService.Tests

# Add references
dotnet add reference ../services/orders-service/OrdersService.csproj
dotnet add package Microsoft.EntityFrameworkCore.InMemory
dotnet add package Moq
```

Example unit test:
```csharp
[Fact]
public async Task CreateOrder_ValidRequest_ReturnsOrder()
{
    // Arrange
    var options = new DbContextOptionsBuilder<OrdersDbContext>()
        .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
        .Options;

    using var context = new OrdersDbContext(options);
    var service = new OrderService(context, Mock.Of<IMessagePublisher>(), Mock.Of<ILogger<OrderService>>());

    var request = new CreateOrderRequest
    {
        CustomerId = "customer-123",
        Items = new List<OrderItemRequest>
        {
            new OrderItemRequest { ProductId = "product-1", ProductName = "Test Product", Quantity = 1, UnitPrice = 10.00m }
        }
    };

    // Act
    var result = await service.CreateOrderAsync(request);

    // Assert
    Assert.NotNull(result);
    Assert.Equal("customer-123", result.CustomerId);
    Assert.Equal(10.00m, result.TotalAmount);
}
```

### Integration Testing

Create integration tests that test the full API:

```csharp
public class OrdersControllerIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public OrdersControllerIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task GetOrders_ReturnsSuccessAndCorrectContentType()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/orders");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("application/json; charset=utf-8", 
            response.Content.Headers.ContentType.ToString());
    }
}
```

### Running Tests

```bash
# Run all tests
dotnet test

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run specific test project
dotnet test OrdersService.Tests/
```

## Code Quality

### Linting and Formatting

Use .editorconfig for consistent formatting:

```ini
root = true

[*]
charset = utf-8
end_of_line = crlf
insert_final_newline = true
indent_style = space
indent_size = 2

[*.cs]
indent_size = 4
```

### Static Analysis

Enable analyzers in project files:

```xml
<PropertyGroup>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsAsErrors />
    <AnalysisMode>Default</AnalysisMode>
</PropertyGroup>

<PackageReference Include="Microsoft.CodeAnalysis.Analyzers" Version="3.3.4" PrivateAssets="all" />
<PackageReference Include="Microsoft.CodeAnalysis.NetAnalyzers" Version="7.0.4" PrivateAssets="all" />
```

### Security Scanning

Use security analyzers:

```xml
<PackageReference Include="SecurityCodeScan.VS2019" Version="5.6.7" PrivateAssets="all" />
```

## Debugging

### Local Debugging

1. Set breakpoints in your IDE
2. Start the service in debug mode
3. Use the Swagger UI to make requests: `https://localhost:7001/swagger`

### Container Debugging

Debug services running in containers:

```bash
# Build debug image
docker build -f Dockerfile.debug -t orders-service:debug .

# Run with debugger port exposed
docker run -p 5005:5005 -p 8080:8080 orders-service:debug
```

### Remote Debugging in Kubernetes

1. Forward ports from pod:
   ```bash
   kubectl port-forward pod/orders-service-xxx 5005:5005
   ```

2. Attach debugger to `localhost:5005`

## Performance

### Monitoring Local Performance

Use Application Insights or other APM tools:

```csharp
// Add to Program.cs
builder.Services.AddApplicationInsightsTelemetry();

// Custom metrics
public class OrderService
{
    private readonly TelemetryClient _telemetryClient;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        using var activity = Activity.StartActivity("OrderService.CreateOrder");
        
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // Business logic here
            var order = await ProcessOrderAsync(request);
            
            _telemetryClient.TrackMetric("OrderCreated", 1);
            return order;
        }
        finally
        {
            stopwatch.Stop();
            _telemetryClient.TrackMetric("OrderCreation.Duration", stopwatch.ElapsedMilliseconds);
        }
    }
}
```

### Load Testing

Use tools like k6 or NBomber:

```javascript
// k6 script
import http from 'k6/http';

export let options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 20 },
    { duration: '30s', target: 0 },
  ],
};

export default function() {
  http.get('https://localhost:7001/api/orders');
}
```

## Environment Management

### Configuration

Use different appsettings files:
- `appsettings.json` - Base configuration
- `appsettings.Development.json` - Development overrides
- `appsettings.Production.json` - Production overrides

### Secrets Management

For local development, use User Secrets:

```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:ServiceBus" "your-connection-string"
```

## Contributing

### Code Standards

1. Follow C# coding conventions
2. Write XML documentation for public APIs
3. Include unit tests for all business logic
4. Use meaningful commit messages
5. Update documentation for API changes

### Pull Request Process

1. Create feature branch from main
2. Implement changes with tests
3. Update documentation
4. Run full test suite
5. Submit pull request with description

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - Feature branches
- `hotfix/*` - Critical fixes