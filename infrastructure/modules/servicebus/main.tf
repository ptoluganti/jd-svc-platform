# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = "${var.project_name}-${var.environment}-sb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-servicebus"
    Environment = var.environment
    Component   = "messaging"
  })
}

# Topics for event-driven communication
resource "azurerm_servicebus_topic" "order_events" {
  name                = "order-events"
  namespace_id        = azurerm_servicebus_namespace.main.id
  enable_partitioning = true
}

resource "azurerm_servicebus_topic" "inventory_events" {
  name                = "inventory-events"
  namespace_id        = azurerm_servicebus_namespace.main.id
  enable_partitioning = true
}

resource "azurerm_servicebus_topic" "payment_events" {
  name                = "payment-events"
  namespace_id        = azurerm_servicebus_namespace.main.id
  enable_partitioning = true
}

resource "azurerm_servicebus_topic" "notification_events" {
  name                = "notification-events"
  namespace_id        = azurerm_servicebus_namespace.main.id
  enable_partitioning = true
}

# Subscriptions for each service
resource "azurerm_servicebus_subscription" "orders_to_inventory" {
  name               = "orders-service"
  topic_id           = azurerm_servicebus_topic.inventory_events.id
  max_delivery_count = 3
}

resource "azurerm_servicebus_subscription" "orders_to_payment" {
  name               = "orders-service"
  topic_id           = azurerm_servicebus_topic.payment_events.id
  max_delivery_count = 3
}

resource "azurerm_servicebus_subscription" "inventory_to_orders" {
  name               = "inventory-service"
  topic_id           = azurerm_servicebus_topic.order_events.id
  max_delivery_count = 3
}

resource "azurerm_servicebus_subscription" "notification_to_orders" {
  name               = "notification-service"
  topic_id           = azurerm_servicebus_topic.order_events.id
  max_delivery_count = 3
}

resource "azurerm_servicebus_subscription" "notification_to_payment" {
  name               = "notification-service"
  topic_id           = azurerm_servicebus_topic.payment_events.id
  max_delivery_count = 3
}