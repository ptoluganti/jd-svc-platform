using Microsoft.EntityFrameworkCore;
using OrdersService.Data;
using OrdersService.Models;

namespace OrdersService.Services;

public class OrderService : IOrderService
{
    private readonly OrdersDbContext _context;
    private readonly IMessagePublisher _messagePublisher;
    private readonly ILogger<OrderService> _logger;

    public OrderService(OrdersDbContext context, IMessagePublisher messagePublisher, ILogger<OrderService> logger)
    {
        _context = context;
        _messagePublisher = messagePublisher;
        _logger = logger;
    }

    public async Task<Order?> GetOrderAsync(int id)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);
    }

    public async Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string customerId)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order
        {
            CustomerId = request.CustomerId,
            Notes = request.Notes,
            Items = request.Items.Select(item => new OrderItem
            {
                ProductId = item.ProductId,
                ProductName = item.ProductName,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice
            }).ToList()
        };

        // Calculate total amount
        order.TotalAmount = order.Items.Sum(item => item.TotalPrice);

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Order {OrderId} created for customer {CustomerId}", order.Id, order.CustomerId);

        // Publish order created event
        await _messagePublisher.PublishOrderEventAsync("OrderCreated", new
        {
            OrderId = order.Id,
            CustomerId = order.CustomerId,
            TotalAmount = order.TotalAmount,
            Items = order.Items.Select(i => new { i.ProductId, i.Quantity, i.UnitPrice })
        });

        return order;
    }

    public async Task<Order?> UpdateOrderStatusAsync(int id, UpdateOrderStatusRequest request)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order == null)
            return null;

        var oldStatus = order.Status;
        order.Status = request.Status;
        order.UpdatedAt = DateTime.UtcNow;
        
        if (!string.IsNullOrEmpty(request.Notes))
        {
            order.Notes = request.Notes;
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("Order {OrderId} status updated from {OldStatus} to {NewStatus}", 
            order.Id, oldStatus, order.Status);

        // Publish status change event
        await _messagePublisher.PublishOrderEventAsync("OrderStatusChanged", new
        {
            OrderId = order.Id,
            CustomerId = order.CustomerId,
            OldStatus = oldStatus.ToString(),
            NewStatus = order.Status.ToString(),
            UpdatedAt = order.UpdatedAt
        });

        return order;
    }

    public async Task<bool> DeleteOrderAsync(int id)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order == null)
            return false;

        // Only allow deletion of pending orders
        if (order.Status != OrderStatus.Pending)
            return false;

        _context.Orders.Remove(order);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Order {OrderId} deleted", id);

        // Publish order deleted event
        await _messagePublisher.PublishOrderEventAsync("OrderDeleted", new
        {
            OrderId = id,
            CustomerId = order.CustomerId
        });

        return true;
    }

    public async Task<IEnumerable<Order>> GetAllOrdersAsync(int page = 1, int pageSize = 20)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .OrderByDescending(o => o.OrderDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
}