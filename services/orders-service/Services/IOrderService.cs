using OrdersService.Models;

namespace OrdersService.Services;

public interface IOrderService
{
    Task<Order?> GetOrderAsync(int id);
    Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string customerId);
    Task<Order> CreateOrderAsync(CreateOrderRequest request);
    Task<Order?> UpdateOrderStatusAsync(int id, UpdateOrderStatusRequest request);
    Task<bool> DeleteOrderAsync(int id);
    Task<IEnumerable<Order>> GetAllOrdersAsync(int page = 1, int pageSize = 20);
}

public interface IMessagePublisher
{
    Task PublishOrderEventAsync(string eventType, object eventData);
}