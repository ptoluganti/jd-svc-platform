output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Container registry login server"
  value       = module.acr.login_server
}

output "acr_name" {
  description = "Container registry name"
  value       = module.acr.name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.aks.fqdn
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.database.server_fqdn
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = module.database.database_name
}

output "servicebus_namespace" {
  description = "Service Bus namespace"
  value       = module.servicebus.namespace_name
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.vault_uri
}

output "application_insights_key" {
  description = "Application Insights instrumentation key"
  value       = var.enable_monitoring ? module.monitoring[0].instrumentation_key : null
  sensitive   = true
}