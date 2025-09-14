variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "sqladmin"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}