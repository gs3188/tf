# Azure Infrastructure as Code with Terraform

This repository contains Terraform configurations for managing Azure infrastructure across multiple layers (Network, Shared Services, and Application).

## Project Structure

```
├── application/              # Application layer resources
│   ├── _app-service.tf      # App service configuration
│   ├── main.tf              # Main configuration file
│   ├── naming.tf            # Naming conventions
│   ├── providers.tf         # Provider configuration
│   ├── variables.tf         # Input variables
│   └── config/              # Environment-specific configurations
│       ├── dev.tfvars      # Development environment variables
│       └── prod.tfvars     # Production environment variables
│
├── backend/                 # Terraform backend configurations
│   ├── dev.tfbackend       # Development backend config
│   └── prod.tfbackend      # Production backend config
│
├── network/                 # Network layer resources
│   ├── _dns-zones.tf       # Private DNS zones
│   ├── _resource-group.tf  # Network resource group
│   ├── _vnet.tf           # Virtual network and subnets
│   ├── main.tf            # Main configuration file
│   ├── naming.tf          # Naming conventions
│   ├── outputs.tf         # Output definitions
│   ├── providers.tf       # Provider configuration
│   ├── variables.tf       # Input variables
│   └── config/           # Environment-specific configurations
│       ├── dev.tfvars   # Development environment variables
│       └── prod.tfvars  # Production environment variables
│
└── shared/                # Shared services layer resources
    ├── _key-vault.tf     # Key Vault configuration
    ├── _postgre-sql.tf   # PostgreSQL configuration
    ├── _resource-group.tf # Shared resource group
    ├── _sql-server.tf    # SQL Server configuration
    ├── _storage-account.tf# Storage account configuration
    ├── main.tf           # Main configuration file
    ├── naming.tf         # Naming conventions
    ├── providers.tf      # Provider configuration
    ├── variables.tf      # Input variables
    └── config/          # Environment-specific configurations
        ├── dev.tfvars  # Development environment variables
        └── prod.tfvars # Production environment variables
```

## Prerequisites

- Terraform 1.12.2 or later
- Azure CLI
- Azure Subscription
- Sufficient permissions to create resources in Azure

## Layer Details

### Network Layer
- Virtual Network with segregated subnets
- Private DNS Zones
- Network Security Groups
- Service Endpoints
- Private Endpoints support

### Shared Layer
- Key Vault with Private Endpoint
- PostgreSQL Server with Private Endpoint
- SQL Server with Private Endpoint
- Storage Account with Private Endpoints for Blob and File
- Centralized resource group with deletion lock

### Application Layer
- App Service configurations
- Integration with network and shared services

## Getting Started

1. Install required tools:
```bash
# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install Azure CLI
brew install azure-cli
```

2. Login to Azure:
```bash
az login
az account set --subscription "Your-Subscription-ID"
```

3. Initialize Terraform for each layer:
```bash
# Network Layer
cd network
terraform init --backend-config="../backend/dev.tfbackend"

# Shared Layer
cd ../shared
terraform init --backend-config="../backend/dev.tfbackend"

# Application Layer
cd ../application
terraform init --backend-config="../backend/dev.tfbackend"
```

4. Deploy the infrastructure:
```bash
# Deploy Network Layer first
cd network
terraform plan -var-file="config/dev.tfvars"
terraform apply -var-file="config/dev.tfvars"

# Deploy Shared Layer next
cd ../shared
terraform plan -var-file="config/dev.tfvars"
terraform apply -var-file="config/dev.tfvars"

# Deploy Application Layer last
cd ../application
terraform plan -var-file="config/dev.tfvars"
terraform apply -var-file="config/dev.tfvars"
```

## Environment Configuration

The project supports multiple environments through separate `.tfvars` files:

- `dev.tfvars`: Development environment configuration
- `prod.tfvars`: Production environment configuration

## Security Features

- Private Endpoints for all PaaS services
- Network isolation through subnet segregation
- Resource group locks to prevent accidental deletion
- Service Endpoints for enhanced security
- Private DNS zones for internal name resolution

## Best Practices

1. Always deploy in this order:
   - Network Layer
   - Shared Layer
   - Application Layer

2. Use separate service principals for different environments

3. Review terraform plan output before applying changes

4. Use resource locks for critical infrastructure

## Contributing

1. Create a new branch for your changes
2. Make your changes and test them
3. Submit a pull request with a clear description of changes

## Maintainers

- gs3188

## License

This project is licensed under the MIT License - see the LICENSE file for details
