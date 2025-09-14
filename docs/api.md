# API Documentation

## Orders Service API

**Base URL**: `https://api.jd-svc-platform-{env}.com/api/orders`

### Authentication

Currently, the API is open. Authentication with Azure AD will be added in future versions.

### Endpoints

#### GET /api/orders

Get all orders with pagination.

**Parameters**:
- `page` (optional): Page number (default: 1)
- `pageSize` (optional): Items per page (default: 20, max: 100)

**Response**:
```json
[
  {
    "id": 1,
    "customerId": "customer-123",
    "orderDate": "2024-01-15T10:30:00Z",
    "status": "Pending",
    "totalAmount": 299.99,
    "items": [
      {
        "id": 1,
        "productId": "product-abc",
        "productName": "Sample Product",
        "quantity": 2,
        "unitPrice": 149.99,
        "totalPrice": 299.98
      }
    ],
    "notes": "Rush delivery requested",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
]
```

#### GET /api/orders/{id}

Get order by ID.

**Response**:
```json
{
  "id": 1,
  "customerId": "customer-123",
  "orderDate": "2024-01-15T10:30:00Z",
  "status": "Pending",
  "totalAmount": 299.99,
  "items": [...],
  "notes": "Rush delivery requested",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

#### GET /api/orders/customer/{customerId}

Get orders by customer ID.

**Response**: Array of order objects (same format as above)

#### POST /api/orders

Create a new order.

**Request Body**:
```json
{
  "customerId": "customer-123",
  "items": [
    {
      "productId": "product-abc",
      "productName": "Sample Product",
      "quantity": 2,
      "unitPrice": 149.99
    }
  ],
  "notes": "Rush delivery requested"
}
```

**Response**: Order object (201 Created)

#### PUT /api/orders/{id}/status

Update order status.

**Request Body**:
```json
{
  "status": "Processing",
  "notes": "Order confirmed and processing"
}
```

**Response**: Updated order object

#### DELETE /api/orders/{id}

Delete an order (only pending orders can be deleted).

**Response**: 204 No Content

### Order Status Values

- `Pending`: Order created, awaiting confirmation
- `Confirmed`: Order confirmed, ready for processing
- `Processing`: Order is being prepared
- `Shipped`: Order has been shipped
- `Delivered`: Order delivered to customer
- `Cancelled`: Order cancelled

## Inventory Service API

**Base URL**: `https://api.jd-svc-platform-{env}.com/api/inventory`

### Endpoints

#### GET /api/inventory/products

Get all products with pagination.

**Parameters**:
- `page` (optional): Page number (default: 1)  
- `pageSize` (optional): Items per page (default: 20, max: 100)
- `category` (optional): Filter by category
- `active` (optional): Filter by active status (true/false)

**Response**:
```json
[
  {
    "id": 1,
    "productId": "product-abc",
    "name": "Sample Product",
    "description": "A sample product description",
    "price": 149.99,
    "stockQuantity": 100,
    "reservedQuantity": 5,
    "availableQuantity": 95,
    "category": "Electronics",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
]
```

#### GET /api/inventory/products/{productId}

Get product by ID.

#### POST /api/inventory/products

Create a new product.

**Request Body**:
```json
{
  "productId": "product-xyz",
  "name": "New Product",
  "description": "Product description",
  "price": 99.99,
  "stockQuantity": 50,
  "category": "Electronics"
}
```

#### PUT /api/inventory/products/{productId}/stock

Update product stock.

**Request Body**:
```json
{
  "productId": "product-abc",
  "quantity": 25,
  "reason": "Restocking"
}
```

#### POST /api/inventory/reservations

Reserve stock for an order.

**Request Body**:
```json
{
  "productId": "product-abc",
  "orderId": "order-123",
  "quantity": 2,
  "expirationMinutes": 30
}
```

### Stock Reservation Status

- `Reserved`: Stock reserved for order
- `Confirmed`: Reservation confirmed (stock allocated)
- `Released`: Reservation released (stock returned)
- `Expired`: Reservation expired automatically

## Common HTTP Status Codes

- `200 OK`: Successful GET request
- `201 Created`: Successful POST request  
- `204 No Content`: Successful DELETE request
- `400 Bad Request`: Invalid request data
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Error Response Format

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "The request data is invalid",
    "details": [
      {
        "field": "customerId",
        "message": "Customer ID is required"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/orders"
}
```

## Event-Driven Architecture

The services communicate through Azure Service Bus events:

### Order Events (Topic: order-events)

- `OrderCreated`: When a new order is created
- `OrderStatusChanged`: When order status changes
- `OrderDeleted`: When an order is deleted

### Inventory Events (Topic: inventory-events)

- `StockUpdated`: When product stock changes
- `StockReserved`: When stock is reserved for an order
- `ReservationExpired`: When a stock reservation expires

## Rate Limiting

- Default: 1000 requests per minute per client
- Burst: Up to 2000 requests in a 5-minute window
- Headers included in responses:
  - `X-RateLimit-Limit`: Rate limit ceiling
  - `X-RateLimit-Remaining`: Number of requests remaining
  - `X-RateLimit-Reset`: UTC timestamp when limit resets

## Postman Collection

A Postman collection with sample requests is available in the `/docs` folder:
- `JD-Services-Platform.postman_collection.json`

Import this collection to quickly test the APIs.

## SDKs and Client Libraries

Client libraries are planned for:
- .NET
- Node.js  
- Python
- Java

These will be available in future releases with built-in retry logic, authentication, and error handling.