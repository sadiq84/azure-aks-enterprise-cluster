variable "environment" {
  description = "Target deployment environment (dev, uat, prod)."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group holding AKS."
  type        = string
  default     = "rg-aks-enterprise-prod"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-core-enterprise-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes release version."
  type        = string
  default     = "1.28.5"
}

variable "vnet_address_space" {
  description = "CIDR range for the AKS Virtual Network."
  type        = list(string)
  default     = ["10.200.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "Subnet CIDR for AKS worker nodes."
  type        = list(string)
  default     = ["10.200.4.0/22"]
}

variable "system_node_count" {
  description = "Initial node count for system pool."
  type        = number
  default     = 3
}

variable "user_node_min_count" {
  description = "Minimum node count for application user pool."
  type        = number
  default     = 3
}

variable "user_node_max_count" {
  description = "Maximum node count for application user pool (autoscaler)."
  type        = number
  default     = 10
}

variable "user_node_vm_size" {
  description = "Compute VM SKU for user workload nodes."
  type        = string
  default     = "Standard_D4s_v5"
}
