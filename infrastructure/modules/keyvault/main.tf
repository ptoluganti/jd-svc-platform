# Generate unique name for Key Vault
resource "random_string" "keyvault_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_key_vault" "main" {
  name                = "${var.project_name}-${var.environment}-kv-${random_string.keyvault_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = false

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-keyvault"
    Environment = var.environment
    Component   = "security"
  })
}