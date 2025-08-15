# Application Layer

This layer contains application-specific infrastructure including AKS and supporting services.

## Resources

- AKS Cluster
- Container Registry (ACR)
- Log Analytics Workspace
- Private Endpoints
- Resource Group
- NGINX Ingress Controller

## Folder Structure
```
application/
├── _aks.tf            # AKS cluster configuration
├── _app-service.tf    # App service configuration
├── _ngingx.tf        # NGINX Ingress Controller configuration
├── main.tf           # Main configuration
├── naming.tf         # Naming conventions
├── providers.tf      # Provider configuration
├── variables.tf      # Variable definitions
└── config/            
    ├── dev.tfvars   # Development variables
    └── prod.tfvars  # Production variables
```

## Prerequisites

- Network and Shared layers must be deployed first
- Azure subscription
- Terraform 1.12.2 or later
- Azure CLI
- Appropriate permissions to create AKS and related services

## AKS Configuration

### Cluster Features

- Multi-zone deployment
- System and User node pools
- Auto-scaling enabled
- Azure CNI networking
- Azure AD integration
- Microsoft Defender
- Private endpoints

### NGINX Ingress Controller

The NGINX Ingress Controller is deployed with the following features:
- Internal Load Balancer configuration
- Automatic SSL/TLS configuration
- Metrics enabled for monitoring
- Resource requests and limits
- Health probe configuration
- DNS label configuration
- Diagnostic settings

### Required Variables

```hcl
environment = "dev"
location    = "eastus"

# AKS
kubernetes_version    = "1.26.3"
system_node_vm_size  = "Standard_D4s_v3"
user_node_vm_size    = "Standard_D8s_v3"
admin_group_object_ids = ["group-id"]

# NGINX Ingress
nginx_ingress_version = "4.7.1"
nginx_replicas        = 2

# Network
service_cidr        = "10.0.0.0/16"
dns_service_ip      = "10.0.0.10"
docker_bridge_cidr  = "172.17.0.1/16"
```

## Deployment

1. Initialize Terraform:
```bash
terraform init --backend-config="../backend/dev.tfbackend"
```

2. Plan the deployment:
```bash
terraform plan -var-file="config/dev.tfvars"
```

3. Apply the configuration:
```bash
terraform apply -var-file="config/dev.tfvars"
```

4. Configure kubectl:
```bash
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```

## Security Features

- Azure AD integration
- Network policies
- Microsoft Defender
- Private networking
- RBAC enabled

## Monitoring

- Container insights
- Log Analytics integration
- Diagnostic settings
- Metric collection

## Best Practices

1. Use separate node pools for system and user workloads
2. Enable auto-scaling
3. Regular security updates
4. Monitor cluster metrics
5. Use resource quotas
6. Implement proper RBAC
