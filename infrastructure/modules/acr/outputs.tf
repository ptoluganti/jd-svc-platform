output "id" {
  description = "Container registry ID"
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "Container registry name"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "Container registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "Container registry admin username"
  value       = azurerm_container_registry.main.admin_username
}

output "admin_password" {
  description = "Container registry admin password"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}