using System.ComponentModel.DataAnnotations;

namespace OrdersService.Models;

public class Order
{
    public int Id { get; set; }
    
    [Required]
    public string CustomerId { get; set; } = string.Empty;
    
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    
    public decimal TotalAmount { get; set; }
    
    public List<OrderItem> Items { get; set; } = new();
    
    public string? Notes { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class OrderItem
{
    public int Id { get; set; }
    
    public int OrderId { get; set; }
    
    public Order Order { get; set; } = null!;
    
    [Required]
    public string ProductId { get; set; } = string.Empty;
    
    [Required]
    public string ProductName { get; set; } = string.Empty;
    
    public int Quantity { get; set; }
    
    public decimal UnitPrice { get; set; }
    
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending,
    Confirmed,
    Processing,
    Shipped,
    Delivered,
    Cancelled
}

public class CreateOrderRequest
{
    [Required]
    public string CustomerId { get; set; } = string.Empty;
    
    [Required]
    public List<OrderItemRequest> Items { get; set; } = new();
    
    public string? Notes { get; set; }
}

public class OrderItemRequest
{
    [Required]
    public string ProductId { get; set; } = string.Empty;
    
    [Required]
    public string ProductName { get; set; } = string.Empty;
    
    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }
    
    [Range(0.01, double.MaxValue)]
    public decimal UnitPrice { get; set; }
}

public class UpdateOrderStatusRequest
{
    [Required]
    public OrderStatus Status { get; set; }
    
    public string? Notes { get; set; }
}