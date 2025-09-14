output "namespace_id" {
  description = "Service Bus namespace ID"
  value       = azurerm_servicebus_namespace.main.id
}

output "namespace_name" {
  description = "Service Bus namespace name"
  value       = azurerm_servicebus_namespace.main.name
}

output "connection_string" {
  description = "Service Bus connection string"
  value       = azurerm_servicebus_namespace.main.default_primary_connection_string
  sensitive   = true
}

output "topics" {
  description = "Service Bus topics"
  value = {
    order_events        = azurerm_servicebus_topic.order_events.name
    inventory_events    = azurerm_servicebus_topic.inventory_events.name
    payment_events      = azurerm_servicebus_topic.payment_events.name
    notification_events = azurerm_servicebus_topic.notification_events.name
  }
}