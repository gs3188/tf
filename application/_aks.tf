# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${local.resource_prefix}-aks"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = azurerm_resource_group.application.name
  dns_prefix          = "${local.resource_prefix}-aks"
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "${local.resource_prefix}-aks-nodes-rg"

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_vm_size
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
    enable_auto_scaling = true
    min_count          = var.system_node_min_count
    max_count          = var.system_node_max_count
    vnet_subnet_id     = data.terraform_remote_state.network.outputs.app_subnet_id
    
    upgrade_settings {
      max_surge = "33%"
    }

    tags = merge(local.common_tags, {
      nodepool-type = "system"
      environment   = var.environment
    })
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled    = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  microsoft_defender {
    enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [0, 1, 2, 3, 4]
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                        = "random"
    max_graceful_termination_sec    = "600"
    max_node_provisioning_time      = "15m"
    max_unready_nodes               = "3"
    max_unready_percentage          = "45"
    new_pod_scale_up_delay         = "10s"
    scale_down_delay_after_add     = "10m"
    scale_down_delay_after_delete  = "10s"
    scale_down_delay_after_failure = "3m"
    scan_interval                  = "10s"
    scale_down_unneeded           = "10m"
    scale_down_unready            = "20m"
    scale_down_utilization_threshold = "0.5"
  }

  tags = merge(local.common_tags, {
    service = "aks-cluster"
  })
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size              = var.user_node_vm_size
  node_count           = var.user_node_count
  zones                = [1, 2, 3]
  enable_auto_scaling  = true
  min_count           = var.user_node_min_count
  max_count           = var.user_node_max_count
  vnet_subnet_id      = data.terraform_remote_state.network.outputs.app_subnet_id

  upgrade_settings {
    max_surge = "33%"
  }

  tags = merge(local.common_tags, {
    nodepool-type = "user"
    environment   = var.environment
  })
}

# Log Analytics Workspace for AKS
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${local.resource_prefix}-aks-logs"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = azurerm_resource_group.application.name
  sku                = "PerGB2018"
  retention_in_days   = 30

  tags = merge(local.common_tags, {
    service = "aks-monitoring"
  })
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                          = replace("${local.resource_prefix}acr", "-", "")
  location                      = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name          = azurerm_resource_group.application.name
  sku                          = "Premium"
  admin_enabled                = false
  public_network_access_enabled = false

  network_rule_set {
    default_action = "Deny"
    virtual_network {
      action    = "Allow"
      subnet_id = data.terraform_remote_state.network.outputs.app_subnet_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  georeplications {
    location                = var.acr_georeplication_location
    zone_redundancy_enabled = true
    tags                    = local.common_tags
  }

  tags = merge(local.common_tags, {
    service = "container-registry"
  })
}

# Private Endpoint for Container Registry
resource "azurerm_private_endpoint" "acr" {
  name                = "${local.resource_prefix}-acr-pe"
  location            = data.terraform_remote_state.network.outputs.network_resource_group_location
  resource_group_name = azurerm_resource_group.application.name
  subnet_id           = data.terraform_remote_state.network.outputs.app_subnet_id

  private_service_connection {
    name                           = "${local.resource_prefix}-acr-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection          = false
    subresource_names            = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.terraform_remote_state.network.outputs.private_dns_zone_id]
  }

  tags = merge(local.common_tags, {
    service = "acr-private-endpoint"
  })
}

# Role Assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# Diagnostic settings for AKS
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${local.resource_prefix}-aks-diag"
  target_resource_id        = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  log {
    category = "kube-apiserver"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-audit"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-controller-manager"
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
