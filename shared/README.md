# Shared Layer

This layer contains shared infrastructure services used across the environment.

## Resources

- Key Vault with Private Endpoint
- PostgreSQL Server with Private Endpoint
- SQL Server with Private Endpoint
- Storage Account with Private Endpoints
- Resource Group with Lock

## Folder Structure
```
shared/
├── _key-vault.tf         # Key Vault configuration
├── _postgre-sql.tf       # PostgreSQL configuration
├── _resource-group.tf    # Shared resource group
├── _sql-server.tf        # SQL Server configuration
├── _storage-account.tf   # Storage account configuration
├── main.tf              # Main configuration
├── naming.tf            # Naming conventions
├── providers.tf         # Provider configuration
├── variables.tf         # Variable definitions
└── config/            
    ├── dev.tfvars      # Development variables
    └── prod.tfvars     # Production variables
```

## Prerequisites

- Network layer must be deployed first
- Azure subscription
- Terraform 1.12.2 or later
- Azure CLI
- Appropriate permissions to create PaaS services

## Configuration

### Required Variables

```hcl
environment = "dev"
location    = "eastus"

# Key Vault
key_vault_sku = "standard"
enable_rbac_authorization = false

# PostgreSQL
postgresql_admin_username = "psqladmin"
postgresql_sku = "GP_Gen5_2"
postgresql_storage_mb = 5120

# SQL Server
mssql_version = "12.0"
mssql_admin_username = "sqladmin"

# Storage Account
storage_allowed_ip_ranges = []
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

## Security Features

- Private Endpoints for all services
- Network isolation
- Resource group lock
- Encryption at rest
- TLS enforcement
- Diagnostic logging

## Private Endpoints

All services are configured with private endpoints:
- Key Vault: vault endpoint
- PostgreSQL: postgresql endpoint
- SQL Server: sqlServer endpoint
- Storage Account: blob and file endpoints

## Monitoring

- Diagnostic settings for all services
- Log Analytics integration
- Metric collection
- Audit logging

## Best Practices

1. Store sensitive values in Key Vault
2. Regular backup verification
3. Monitor service metrics
4. Review access policies regularly
5. Keep services updated
