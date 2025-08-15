# NGINX Ingress Controller Resources
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = var.nginx_ingress_version

  set {
    name  = "controller.replicaCount"
    value = var.nginx_replicas
  }

  set {
    name  = "controller.nodeSelector.\"kubernetes\\.io/os\""
    value = "linux"
  }

  set {
    name  = "controller.admissionWebhooks.patch.nodeSelector.\"kubernetes\\.io/os\""
    value = "linux"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = "${local.resource_prefix}-ingress"
  }

  # Internal Load Balancer configuration
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet"
    value = "app-subnet"
  }

  # Resource requests and limits
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "90Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "180Mi"
  }

  # Enable metrics for monitoring
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }

  # Configure SSL/TLS
  set {
    name  = "controller.config.ssl-protocols"
    value = "TLSv1.2 TLSv1.3"
  }

  set {
    name  = "controller.config.ssl-ciphers"
    value = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
  }

  depends_on = [
    azurerm_kubernetes_cluster.main
  ]
}

# Diagnostic settings for NGINX Load Balancer
resource "azurerm_monitor_diagnostic_setting" "nginx_lb" {
  name                       = "${local.resource_prefix}-nginx-lb-diag"
  target_resource_id         = data.azurerm_lb.nginx.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}

# Data source to get the NGINX Load Balancer details
data "azurerm_lb" "nginx" {
  name                = "${local.resource_prefix}-nginx-lb"
  resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group

  depends_on = [
    helm_release.nginx_ingress
  ]
}

# NSG Rules for NGINX Ingress
resource "azurerm_network_security_rule" "nginx_ingress" {
  name                        = "allow-nginx-ingress"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = data.terraform_remote_state.network.outputs.network_resource_group_name
  network_security_group_name = data.terraform_remote_state.network.outputs.app_nsg_id

  depends_on = [
    azurerm_kubernetes_cluster.main
  ]
}
