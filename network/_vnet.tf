# Main Virtual Network
resource "azurerm_virtual_network" "main" {
    name                = "${local.resource_prefix}-vnet"
    address_space       = var.vnet_address_space
    location            = azurerm_resource_group.network.location
    resource_group_name = azurerm_resource_group.network.name

    tags = merge(local.common_tags, {
        service = "virtual-network"
    })
}

# Application Subnet
resource "azurerm_subnet" "app_subnet" {
    name                                           = "${local.resource_prefix}-app-subnet"
    resource_group_name                            = azurerm_resource_group.network.name
    virtual_network_name                           = azurerm_virtual_network.main.name
    address_prefixes                               = [var.app_subnet_prefix]
    private_endpoint_network_policies_enabled      = true
    private_link_service_network_policies_enabled  = true

    service_endpoints = [
        "Microsoft.KeyVault",
        "Microsoft.Sql",
        "Microsoft.Storage",
        "Microsoft.Web"
    ]
}

# Database Subnet
resource "azurerm_subnet" "db_subnet" {
    name                                           = "${local.resource_prefix}-db-subnet"
    resource_group_name                            = azurerm_resource_group.network.name
    virtual_network_name                           = azurerm_virtual_network.main.name
    address_prefixes                               = [var.db_subnet_prefix]
    private_endpoint_network_policies_enabled      = true
    private_link_service_network_policies_enabled  = true

    service_endpoints = [
        "Microsoft.Sql",
        "Microsoft.Storage"
    ]
}

# Gateway Subnet
resource "azurerm_subnet" "gateway_subnet" {
    name                                           = "GatewaySubnet" # This name is required by Azure
    resource_group_name                            = azurerm_resource_group.network.name
    virtual_network_name                           = azurerm_virtual_network.main.name
    address_prefixes                               = [var.gateway_subnet_prefix]
}