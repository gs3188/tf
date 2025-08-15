# Application Layer Variables

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

# AKS Configuration Variables
variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy"
  type        = string
  default     = "1.26.3"
}

# System Node Pool Variables
variable "system_node_count" {
  description = "Initial number of nodes in system node pool"
  type        = number
  default     = 3
}

variable "system_node_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "system_node_min_count" {
  description = "Minimum number of nodes in system node pool"
  type        = number
  default     = 3
}

variable "system_node_max_count" {
  description = "Maximum number of nodes in system node pool"
  type        = number
  default     = 5
}

# User Node Pool Variables
variable "user_node_count" {
  description = "Initial number of nodes in user node pool"
  type        = number
  default     = 2
}

variable "user_node_vm_size" {
  description = "VM size for user node pool"
  type        = string
  default     = "Standard_D8s_v3"
}

variable "user_node_min_count" {
  description = "Minimum number of nodes in user node pool"
  type        = number
  default     = 2
}

variable "user_node_max_count" {
  description = "Maximum number of nodes in user node pool"
  type        = number
  default     = 10
}

# Network Variables
variable "service_cidr" {
  description = "CIDR range for kubernetes services"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for kubernetes DNS service"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR range for docker bridge network"
  type        = string
  default     = "172.17.0.1/16"
}

# RBAC Variables

# NGINX Ingress Variables
variable "nginx_ingress_version" {
  description = "Version of NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.7.1"
}

variable "nginx_replicas" {
  description = "Number of NGINX Ingress Controller replicas"
  type        = number
  default     = 2
}
variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = []
}

# ACR Variables
variable "acr_georeplication_location" {
  description = "Location for ACR geo-replication"
  type        = string
  default     = "westus2"  # Change based on your requirements
}
