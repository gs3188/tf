# Shared Layer Variables

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

# PostgreSQL variables
variable "postgresql_admin_username" {
  description = "Administrator username for PostgreSQL server"
  type        = string
}

variable "postgresql_admin_password" {
  description = "Administrator password for PostgreSQL server"
  type        = string
  sensitive   = true
}

variable "postgresql_sku" {
  description = "SKU name for PostgreSQL server"
  type        = string
  default     = "GP_Gen5_2"
}

variable "postgresql_version" {
  description = "Version of PostgreSQL server"
  type        = string
  default     = "11"
}

variable "postgresql_storage_mb" {
  description = "Storage size in MB for PostgreSQL server"
  type        = number
  default     = 5120
}

variable "postgresql_configurations" {
  description = "Map of PostgreSQL configurations"
  type        = map(string)
  default     = {}
}

# SQL Server variables
variable "mssql_version" {
  description = "Version of SQL Server"
  type        = string
  default     = "12.0"
}

variable "mssql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
}

variable "mssql_admin_password" {
  description = "Administrator password for SQL Server"
  type        = string
  sensitive   = true
}

variable "mssql_azure_ad_admin_username" {
  description = "Azure AD administrator username for SQL Server"
  type        = string
}

variable "mssql_azure_ad_admin_object_id" {
  description = "Azure AD administrator object ID for SQL Server"
  type        = string
}

variable "mssql_firewall_rules" {
  description = "Map of firewall rules for SQL Server"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

# Storage Account variables
variable "storage_allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the Storage Account"
  type        = list(string)
  default     = []
}

# Key Vault specific variables
variable "key_vault_sku" {
  description = "The SKU name of the Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

variable "enable_rbac_authorization" {
  description = "Boolean flag to specify whether Azure RBAC is used for authorization."
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

variable "access_policies" {
  description = "Map of access policies for the Key Vault"
  type = map(object({
    object_id               = string
    key_permissions        = list(string)
    secret_permissions     = list(string)
    certificate_permissions = list(string)
  }))
  default = {}
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace for diagnostics"
  type        = string
}


