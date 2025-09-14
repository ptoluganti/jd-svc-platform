using System.ComponentModel.DataAnnotations;

namespace InventoryService.Models;

public class Product
{
    public int Id { get; set; }
    
    [Required]
    public string ProductId { get; set; } = string.Empty;
    
    [Required]
    public string Name { get; set; } = string.Empty;
    
    public string? Description { get; set; }
    
    public decimal Price { get; set; }
    
    public int StockQuantity { get; set; }
    
    public int ReservedQuantity { get; set; }
    
    public int AvailableQuantity => StockQuantity - ReservedQuantity;
    
    public string? Category { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class StockReservation
{
    public int Id { get; set; }
    
    [Required]
    public string ProductId { get; set; } = string.Empty;
    
    [Required]
    public string OrderId { get; set; } = string.Empty;
    
    public int Quantity { get; set; }
    
    public DateTime ReservedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime ExpiresAt { get; set; }
    
    public ReservationStatus Status { get; set; } = ReservationStatus.Reserved;
}

public enum ReservationStatus
{
    Reserved,
    Confirmed,
    Released,
    Expired
}

public class UpdateStockRequest
{
    [Required]
    public string ProductId { get; set; } = string.Empty;
    
    public int Quantity { get; set; }
    
    public string? Reason { get; set; }
}

public class ReserveStockRequest
{
    [Required]
    public string ProductId { get; set; } = string.Empty;
    
    [Required]
    public string OrderId { get; set; } = string.Empty;
    
    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }
    
    public int ExpirationMinutes { get; set; } = 30;
}