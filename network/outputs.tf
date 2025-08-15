# Virtual Network Outputs
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

# Subnet Outputs
output "app_subnet_id" {
  description = "The ID of the application subnet"
  value       = azurerm_subnet.app_subnet.id
}

output "db_subnet_id" {
  description = "The ID of the database subnet"
  value       = azurerm_subnet.db_subnet.id
}

output "gateway_subnet_id" {
  description = "The ID of the gateway subnet"
  value       = azurerm_subnet.gateway_subnet.id
}

# Network Security Group Outputs
output "app_nsg_id" {
  description = "The ID of the application tier network security group"
  value       = azurerm_network_security_group.app_nsg.id
}

output "db_nsg_id" {
  description = "The ID of the database tier network security group"
  value       = azurerm_network_security_group.db_nsg.id
}

# Resource Group Outputs
output "network_resource_group_name" {
  description = "The name of the network resource group"
  value       = azurerm_resource_group.network.name
}

output "network_resource_group_location" {
  description = "The location of the network resource group"
  value       = azurerm_resource_group.network.location
}

# DNS Zone Outputs
output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.private.id
}

output "private_dns_zone_name" {
  description = "The name of the private DNS zone"
  value       = azurerm_private_dns_zone.private.name
}

# Route Table Outputs
output "route_table_id" {
  description = "The ID of the main route table"
  value       = azurerm_route_table.main.id
}

# Network Watcher Outputs
output "network_watcher_id" {
  description = "The ID of the Network Watcher"
  value       = azurerm_network_watcher.main.id
}

# Load Balancer Outputs (if applicable)
output "load_balancer_public_ip" {
  description = "The public IP address of the load balancer"
  value       = try(azurerm_public_ip.lb[0].ip_address, null)
}

output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = try(azurerm_lb.main[0].id, null)
}

# Firewall Outputs (if applicable)
output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall"
  value       = try(azurerm_firewall.main[0].ip_configuration[0].private_ip_address, null)
}

output "firewall_public_ip" {
  description = "The public IP address of the Azure Firewall"
  value       = try(azurerm_public_ip.fw[0].ip_address, null)
}

# Service Endpoints
output "available_service_endpoints" {
  description = "List of available service endpoints in the main subnet"
  value       = azurerm_subnet.app_subnet.service_endpoints
}

# Network Details
output "network_details" {
  description = "A map of all network details that might be needed by other layers"
  value = {
    vnet = {
      id            = azurerm_virtual_network.main.id
      name          = azurerm_virtual_network.main.name
      address_space = azurerm_virtual_network.main.address_space
    }
    subnets = {
      app = {
        id             = azurerm_subnet.app_subnet.id
        name           = azurerm_subnet.app_subnet.name
        address_prefix = azurerm_subnet.app_subnet.address_prefixes[0]
      }
      db = {
        id             = azurerm_subnet.db_subnet.id
        name           = azurerm_subnet.db_subnet.name
        address_prefix = azurerm_subnet.db_subnet.address_prefixes[0]
      }
      gateway = {
        id             = azurerm_subnet.gateway_subnet.id
        name           = azurerm_subnet.gateway_subnet.name
        address_prefix = azurerm_subnet.gateway_subnet.address_prefixes[0]
      }
    }
    security_groups = {
      app = azurerm_network_security_group.app_nsg.id
      db  = azurerm_network_security_group.db_nsg.id
    }
    dns = {
      private_zone_id   = azurerm_private_dns_zone.private.id
      private_zone_name = azurerm_private_dns_zone.private.name
    }
  }
}

# Diagnostic Settings (if applicable)
output "diagnostic_settings" {
  description = "The IDs of various diagnostic settings"
  value = {
    network_security_group = try(azurerm_monitor_diagnostic_setting.nsg[0].id, null)
    virtual_network       = try(azurerm_monitor_diagnostic_setting.vnet[0].id, null)
  }
}
