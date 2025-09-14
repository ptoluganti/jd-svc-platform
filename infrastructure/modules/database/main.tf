# Generate random password
resource "random_password" "sql_admin" {
  length  = 16
  special = true
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.project_name}-${var.environment}-sql"
  resource_group_name          = var.resource_group_name
  location                    = var.location
  version                     = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = random_password.sql_admin.result

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-sql"
    Environment = var.environment
    Component   = "database"
  })
}

# SQL Database for Orders
resource "azurerm_mssql_database" "orders" {
  name      = "orders"
  server_id = azurerm_mssql_server.main.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  
  sku_name = var.environment == "prod" ? "S2" : "S1"
  
  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-orders-db"
    Environment = var.environment
    Component   = "database"
  })
}

# SQL Database for Inventory  
resource "azurerm_mssql_database" "inventory" {
  name      = "inventory"
  server_id = azurerm_mssql_server.main.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  
  sku_name = var.environment == "prod" ? "S2" : "S1"
  
  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-inventory-db"
    Environment = var.environment
    Component   = "database"
  })
}

# SQL Database for Users
resource "azurerm_mssql_database" "users" {
  name      = "users"
  server_id = azurerm_mssql_server.main.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  
  sku_name = var.environment == "prod" ? "S2" : "S1"
  
  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-users-db"
    Environment = var.environment
    Component   = "database"
  })
}

# Firewall rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}