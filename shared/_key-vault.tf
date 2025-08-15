

# Get the current client configuration from Azure
data "azurerm_client_config" "current" {}

# Key Vault resource
resource "azurerm_key_vault" "main" {
  name                = "${local.resource_prefix}-kv"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = var.key_vault_sku

  # Enable soft delete and purge protection
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization = var.enable_rbac_authorization

  # Network configuration
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [
      data.terraform_remote_state.network.outputs.app_subnet_id,
      data.terraform_remote_state.network.outputs.db_subnet_id
    ]
    ip_rules = var.allowed_ip_ranges
  }

  # Tags
  tags = merge(local.common_tags, {
    service = "key-vault"
  })
}

# Default access policy for the deploying service principal
resource "azurerm_key_vault_access_policy" "deployer" {
  count = var.enable_rbac_authorization ? 0 : 1

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore"
  ]
}

# Additional access policies based on provided configurations
resource "azurerm_key_vault_access_policy" "additional" {
  for_each = var.enable_rbac_authorization ? {} : var.access_policies

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
}

# Diagnostic settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "${local.resource_prefix}-kv-diag"
  target_resource_id        = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  name                = "${local.resource_prefix}-kv-pe"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.app_subnet_id

  private_service_connection {
    name                           = "${local.resource_prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection          = false
    subresource_names            = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.terraform_remote_state.network.outputs.private_dns_zone_id]
  }

  tags = merge(local.common_tags, {
    service = "key-vault-private-endpoint"
  })
}

# Private DNS A record for Key Vault
resource "azurerm_private_dns_a_record" "key_vault" {
  name                = azurerm_key_vault.main.name
  zone_name           = data.terraform_remote_state.network.outputs.private_dns_zone_name
  resource_group_name = data.terraform_remote_state.network.outputs.network_resource_group_name
  ttl                = 300
  records            = [azurerm_private_endpoint.key_vault.private_service_connection[0].private_ip_address]

  tags = merge(local.common_tags, {
    service = "key-vault-dns"
  })
}

# Example secrets (uncomment and modify as needed)
# resource "azurerm_key_vault_secret" "example" {
#   name         = "example-secret"
#   value        = var.example_secret_value
#   key_vault_id = azurerm_key_vault.main.id
#
#   tags = merge(local.common_tags, {
#     service = "example"
#   })
# }
