using Azure.Messaging.ServiceBus;
using System.Text.Json;

namespace OrdersService.Services;

public class ServiceBusMessagePublisher : IMessagePublisher
{
    private readonly ServiceBusClient _serviceBusClient;
    private readonly ILogger<ServiceBusMessagePublisher> _logger;
    private readonly string _topicName = "order-events";

    public ServiceBusMessagePublisher(ServiceBusClient serviceBusClient, ILogger<ServiceBusMessagePublisher> logger)
    {
        _serviceBusClient = serviceBusClient;
        _logger = logger;
    }

    public async Task PublishOrderEventAsync(string eventType, object eventData)
    {
        try
        {
            var sender = _serviceBusClient.CreateSender(_topicName);

            var messageBody = JsonSerializer.Serialize(new
            {
                EventType = eventType,
                Data = eventData,
                Timestamp = DateTime.UtcNow,
                Source = "OrdersService"
            });

            var message = new ServiceBusMessage(messageBody)
            {
                Subject = eventType,
                MessageId = Guid.NewGuid().ToString(),
                ContentType = "application/json"
            };

            // Add custom properties for routing
            message.ApplicationProperties.Add("EventType", eventType);
            message.ApplicationProperties.Add("Source", "OrdersService");

            await sender.SendMessageAsync(message);

            _logger.LogInformation("Published event {EventType} to topic {TopicName}", eventType, _topicName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to publish event {EventType} to Service Bus", eventType);
            throw;
        }
    }
}