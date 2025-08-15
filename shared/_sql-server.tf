# SQL Server
resource "azurerm_mssql_server" "main" {
  name                = "${local.resource_prefix}-sql"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name

  version                      = var.mssql_version
  administrator_login          = var.mssql_admin_username
  administrator_login_password = var.mssql_admin_password

  public_network_access_enabled = false
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = var.mssql_azure_ad_admin_username
    object_id     = var.mssql_azure_ad_admin_object_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.common_tags, {
    service = "mssql"
  })
}

# SQL Server Firewall Rules
resource "azurerm_mssql_firewall_rule" "rules" {
  for_each = var.mssql_firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "mssql" {
  name                = "${local.resource_prefix}-sql-pe"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.db_subnet_id

  private_service_connection {
    name                           = "${local.resource_prefix}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
    is_manual_connection          = false
    subresource_names            = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.terraform_remote_state.network.outputs.private_dns_zone_id]
  }

  tags = merge(local.common_tags, {
    service = "mssql-private-endpoint"
  })
}

# Private DNS A record for SQL Server
resource "azurerm_private_dns_a_record" "mssql" {
  name                = azurerm_mssql_server.main.name
  zone_name           = data.terraform_remote_state.network.outputs.private_dns_zone_name
  resource_group_name = data.terraform_remote_state.network.outputs.network_resource_group_name
  ttl                = 300
  records            = [azurerm_private_endpoint.mssql.private_service_connection[0].private_ip_address]

  tags = merge(local.common_tags, {
    service = "mssql-dns"
  })
}

# Diagnostic settings for SQL Server
resource "azurerm_monitor_diagnostic_setting" "mssql" {
  name                       = "${local.resource_prefix}-sql-diag"
  target_resource_id         = azurerm_mssql_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "SQLSecurityAuditEvents"
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
