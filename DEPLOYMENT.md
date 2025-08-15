# Deployment Guide

This guide explains the deployment process for the entire infrastructure.

## Prerequisites

### Tools
- Terraform 1.12.2 or later
- Azure CLI 2.40.0 or later
- kubectl (for AKS management)
- Git

### Azure Requirements
- Azure subscription
- Service Principal with required permissions
- Azure AD access for RBAC configuration

## Environment Setup

1. Install required tools:
```bash
# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install Azure CLI
brew install azure-cli

# Install kubectl
az aks install-cli
```

2. Configure Azure authentication:
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "Your-Subscription-ID"
```

3. Configure backend storage:
```bash
# Create resource group
az group create --name terraform-state-rg --location eastus

# Create storage account
az storage account create \
  --name tfstate$ENVIRONMENT \
  --resource-group terraform-state-rg \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name tfstate$ENVIRONMENT
```

## Deployment Order

The infrastructure must be deployed in the following order:

1. Network Layer
2. Shared Layer
3. Application Layer

### 1. Network Layer Deployment

```bash
cd network
terraform init --backend-config="../backend/dev.tfbackend"
terraform plan -var-file="config/dev.tfvars"
terraform apply -var-file="config/dev.tfvars"
```

### 2. Shared Layer Deployment

```bash
cd ../shared
terraform init --backend-config="../backend/dev.tfbackend"
terraform plan -var-file="config/dev.tfvars"
terraform apply -var-file="config/dev.tfvars"
```

### 3. Application Layer Deployment

```bash
cd ../application
terraform init --backend-config="../backend/dev.tfbackend"
terraform plan -var-file="config/dev.tfvars"
terraform apply -var-file="config/dev.tfvars"
```

## Environment Configuration

### Backend Configuration
Create environment-specific backend configs:

`backend/dev.tfbackend`:
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstatedev"
container_name       = "tfstate"
key                 = "dev.tfstate"
```

`backend/prod.tfbackend`:
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstateprod"
container_name       = "tfstate"
key                 = "prod.tfstate"
```

## Post-Deployment

### AKS Configuration
```bash
# Get credentials
az aks get-credentials --resource-group <resource-group> --name <cluster-name>

# Verify connection
kubectl get nodes
```

### Verify Private Endpoints
1. Check DNS resolution
2. Verify private IP connectivity
3. Test service access

## Monitoring Setup

1. Review Log Analytics workspace
2. Configure alerts
3. Set up dashboards

## Security Considerations

1. Review RBAC assignments
2. Check network security groups
3. Verify private endpoints
4. Enable monitoring
5. Configure backup policies

## Troubleshooting

### Common Issues

1. Terraform state lock:
```bash
az storage blob lease break -b <state-file> -c tfstate
```

2. Private endpoint connectivity:
```bash
# Test DNS resolution
nslookup <private-endpoint-name>.<service>.privatelink.azure.net
```

3. AKS connectivity:
```bash
# Test kubectl
kubectl cluster-info
```

## Maintenance

### Regular Tasks

1. Update Terraform providers
2. Rotate credentials
3. Review security settings
4. Check for updates
5. Monitor costs

### Backup Procedures

1. Export Terraform state
2. Backup key configurations
3. Document changes

## Rollback Procedures

1. Maintain state backups
2. Document dependencies
3. Test recovery procedures

## Best Practices

1. Always use version control
2. Test in dev first
3. Use consistent naming
4. Implement proper tagging
5. Monitor costs
6. Regular security reviews
7. Keep documentation updated
