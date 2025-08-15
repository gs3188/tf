# Private DNS Zones for Azure Services
resource "azurerm_private_dns_zone" "blob" {
    name                = "privatelink.blob.core.windows.net"
    resource_group_name = azurerm_resource_group.network.name
    
    tags = merge(local.common_tags, {
        service = "dns-blob"
    })
}

resource "azurerm_private_dns_zone" "vault" {
    name                = "privatelink.vaultcore.azure.net"
    resource_group_name = azurerm_resource_group.network.name
    
    tags = merge(local.common_tags, {
        service = "dns-keyvault"
    })
}

resource "azurerm_private_dns_zone" "app_service" {
    name                = "privatelink.azurewebsites.net"
    resource_group_name = azurerm_resource_group.network.name
    
    tags = merge(local.common_tags, {
        service = "dns-appservice"
    })
}

resource "azurerm_private_dns_zone" "sql_server" {
    name                = "privatelink.database.windows.net"
    resource_group_name = azurerm_resource_group.network.name
    
    tags = merge(local.common_tags, {
        service = "dns-sqlserver"
    })
}