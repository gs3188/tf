# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${replace(local.resource_prefix, "-", "")}st"
  location                 = azurerm_resource_group.shared.location
  resource_group_name      = azurerm_resource_group.shared.name
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"

  enable_https_traffic_only       = true
  min_tls_version                = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  
  network_rules {
    default_action = "Deny"
    ip_rules       = var.storage_allowed_ip_ranges
    virtual_network_subnet_ids = [
      data.terraform_remote_state.network.outputs.app_subnet_id
    ]
  }

  tags = merge(local.common_tags, {
    service = "storage"
  })
}

# Private Endpoint for Blob Storage
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "${local.resource_prefix}-st-blob-pe"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.app_subnet_id

  private_service_connection {
    name                           = "${local.resource_prefix}-st-blob-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection          = false
    subresource_names            = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.terraform_remote_state.network.outputs.private_dns_zone_id]
  }

  tags = merge(local.common_tags, {
    service = "storage-blob-private-endpoint"
  })
}

# Private Endpoint for File Storage
resource "azurerm_private_endpoint" "storage_file" {
  name                = "${local.resource_prefix}-st-file-pe"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.app_subnet_id

  private_service_connection {
    name                           = "${local.resource_prefix}-st-file-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection          = false
    subresource_names            = ["file"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.terraform_remote_state.network.outputs.private_dns_zone_id]
  }

  tags = merge(local.common_tags, {
    service = "storage-file-private-endpoint"
  })
}

# Private DNS A records for Storage Account
resource "azurerm_private_dns_a_record" "storage_blob" {
  name                = "${azurerm_storage_account.main.name}-blob"
  zone_name           = data.terraform_remote_state.network.outputs.private_dns_zone_name
  resource_group_name = data.terraform_remote_state.network.outputs.network_resource_group_name
  ttl                = 300
  records            = [azurerm_private_endpoint.storage_blob.private_service_connection[0].private_ip_address]

  tags = merge(local.common_tags, {
    service = "storage-blob-dns"
  })
}

resource "azurerm_private_dns_a_record" "storage_file" {
  name                = "${azurerm_storage_account.main.name}-file"
  zone_name           = data.terraform_remote_state.network.outputs.private_dns_zone_name
  resource_group_name = data.terraform_remote_state.network.outputs.network_resource_group_name
  ttl                = 300
  records            = [azurerm_private_endpoint.storage_file.private_service_connection[0].private_ip_address]

  tags = merge(local.common_tags, {
    service = "storage-file-dns"
  })
}

# Diagnostic settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = "${local.resource_prefix}-st-diag"
  target_resource_id         = azurerm_storage_account.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "Capacity"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
