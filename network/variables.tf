# Network Layer Variables

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

# Network Configuration Variables
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_prefix" {
  description = "Address prefix for the application subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "db_subnet_prefix" {
  description = "Address prefix for the database subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "gateway_subnet_prefix" {
  description = "Address prefix for the gateway subnet"
  type        = string
  default     = "10.0.2.0/24"
}
