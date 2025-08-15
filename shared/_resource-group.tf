# Shared Layer Resource Group
resource "azurerm_resource_group" "shared" {
  name     = "${local.resource_prefix}-shared-rg"
  location = var.location

  tags = merge(local.common_tags, {
    service = "shared-infrastructure"
  })
}

# Lock the resource group to prevent accidental deletion
resource "azurerm_management_lock" "shared_rg" {
  name       = "${local.resource_prefix}-shared-rg-lock"
  scope      = azurerm_resource_group.shared.id
  lock_level = "CanNotDelete"
  notes      = "Protect shared infrastructure resources from accidental deletion"
}
