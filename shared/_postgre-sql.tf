# PostgreSQL Server
resource "azurerm_postgresql_server" "main" {
  name                = "${local.resource_prefix}-psql"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name

  administrator_login          = var.postgresql_admin_username
  administrator_login_password = var.postgresql_admin_password

  sku_name   = var.postgresql_sku
  version    = var.postgresql_version
  storage_mb = var.postgresql_storage_mb

  backup_retention_days        = 7
  geo_redundant_backup_enabled = var.environment == "prod" ? true : false
  auto_grow_enabled           = true
  
  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = merge(local.common_tags, {
    service = "postgresql"
  })
}

# PostgreSQL Configuration
resource "azurerm_postgresql_configuration" "configurations" {
  for_each            = var.postgresql_configurations
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.main.name
  value               = each.value
}

# Private Endpoint for PostgreSQL
resource "azurerm_private_endpoint" "postgresql" {
  name                = "${local.resource_prefix}-psql-pe"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.db_subnet_id

  private_service_connection {
    name                           = "${local.resource_prefix}-psql-psc"
    private_connection_resource_id = azurerm_postgresql_server.main.id
    is_manual_connection          = false
    subresource_names            = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.terraform_remote_state.network.outputs.private_dns_zone_id]
  }

  tags = merge(local.common_tags, {
    service = "postgresql-private-endpoint"
  })
}

# Private DNS A record for PostgreSQL
resource "azurerm_private_dns_a_record" "postgresql" {
  name                = azurerm_postgresql_server.main.name
  zone_name           = data.terraform_remote_state.network.outputs.private_dns_zone_name
  resource_group_name = data.terraform_remote_state.network.outputs.network_resource_group_name
  ttl                = 300
  records            = [azurerm_private_endpoint.postgresql.private_service_connection[0].private_ip_address]

  tags = merge(local.common_tags, {
    service = "postgresql-dns"
  })
}

# Diagnostic settings for PostgreSQL
resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  name                       = "${local.resource_prefix}-psql-diag"
  target_resource_id         = azurerm_postgresql_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "PostgreSQLLogs"
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
