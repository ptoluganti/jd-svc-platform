resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project_name, "-", "")}${var.environment}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-acr"
    Environment = var.environment
    Component   = "container-registry"
  })
}