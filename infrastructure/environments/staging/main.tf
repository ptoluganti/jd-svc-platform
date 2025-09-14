terraform {
  backend "azurerm" {
    resource_group_name  = "jd-svc-platform-tfstate-rg"
    storage_account_name = "jdsvcplatformtfstate"
    container_name       = "tfstate"
    key                  = "staging.terraform.tfstate"
  }
}

# Include the main configuration
module "main" {
  source = "../../"
  
  environment      = var.environment
  location         = var.location
  project_name     = var.project_name
  aks_node_count   = var.aks_node_count
  aks_node_vm_size = var.aks_node_vm_size
  tags             = var.tags
}

# Variables specific to staging environment
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aks_node_count" {
  description = "Number of AKS nodes"
  type        = number
}

variable "aks_node_vm_size" {
  description = "AKS node VM size"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

# Output key values
output "acr_login_server" {
  value = module.main.acr_login_server
}

output "aks_cluster_name" {
  value = module.main.aks_cluster_name
}

output "resource_group_name" {
  value = module.main.resource_group_name
}