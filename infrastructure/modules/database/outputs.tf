output "server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "SQL Server name"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_name" {
  description = "Primary database name"
  value       = azurerm_mssql_database.orders.name
}

output "admin_username" {
  description = "SQL Server admin username"
  value       = azurerm_mssql_server.main.administrator_login
}

output "admin_password" {
  description = "SQL Server admin password"
  value       = random_password.sql_admin.result
  sensitive   = true
}

output "connection_string_orders" {
  description = "Connection string for Orders database"
  value       = "Server=${azurerm_mssql_server.main.fully_qualified_domain_name};Database=${azurerm_mssql_database.orders.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=${random_password.sql_admin.result};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive   = true
}

output "connection_string_inventory" {
  description = "Connection string for Inventory database"
  value       = "Server=${azurerm_mssql_server.main.fully_qualified_domain_name};Database=${azurerm_mssql_database.inventory.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=${random_password.sql_admin.result};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive   = true
}

output "connection_string_users" {
  description = "Connection string for Users database"
  value       = "Server=${azurerm_mssql_server.main.fully_qualified_domain_name};Database=${azurerm_mssql_database.users.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=${random_password.sql_admin.result};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive   = true
}