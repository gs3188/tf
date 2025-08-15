# Network Layer Resource Group
resource "azurerm_resource_group" "network" {
  name     = "${local.resource_prefix}-network-rg"
  location = var.location

  tags = merge(local.common_tags, {
    service = "network-infrastructure"
  })
}

# Lock the resource group to prevent accidental deletion
resource "azurerm_management_lock" "network_rg" {
  name       = "${local.resource_prefix}-network-rg-lock"
  scope      = azurerm_resource_group.network.id
  lock_level = "CanNotDelete"
  notes      = "Protect network infrastructure resources from accidental deletion"
}