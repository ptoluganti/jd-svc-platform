# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# Container Registry Module
module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  tags               = var.tags
}

# AKS Cluster Module
module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  node_count         = var.aks_node_count
  node_vm_size       = var.aks_node_vm_size
  acr_id             = module.acr.id
  tags               = var.tags
}

# Database Module
module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  admin_username     = var.sql_admin_username
  tags               = var.tags
}

# Service Bus Module
module "servicebus" {
  source              = "./modules/servicebus"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  tags               = var.tags
}

# Key Vault Module
module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  tags               = var.tags
}

# Monitoring Module (optional)
module "monitoring" {
  count               = var.enable_monitoring ? 1 : 0
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = var.project_name
  tags               = var.tags
}