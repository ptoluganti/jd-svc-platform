resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project_name}-${var.environment}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_name}-${var.environment}-aks"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    
    # Enable auto-scaling
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 10
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-aks"
    Environment = var.environment
    Component   = "kubernetes"
  })
}

# Grant AKS access to ACR
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = var.acr_id
  skip_service_principal_aad_check = true
}