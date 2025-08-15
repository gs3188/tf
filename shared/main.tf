# Data source for the network layer state
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate${var.environment}"
    container_name       = "tfstate"
    key                 = "network.tfstate"
  }
}