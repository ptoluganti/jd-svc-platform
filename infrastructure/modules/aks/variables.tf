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

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "VM size for the nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "acr_id" {
  description = "Container registry ID for AKS to pull images"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}