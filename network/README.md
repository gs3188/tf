# Network Layer

This layer contains the core networking infrastructure for the Azure environment.

## Resources

- Virtual Network
- Subnets (Application, Database, Gateway)
- Private DNS Zones
- Network Security Groups
- Service Endpoints
- Resource Group with Lock

## Folder Structure
```
network/
├── _dns-zones.tf        # Private DNS zones for Azure services
├── _resource-group.tf   # Network resource group
├── _vnet.tf            # Virtual network and subnets
├── main.tf             # Main configuration
├── naming.tf           # Naming conventions
├── outputs.tf          # Output definitions
├── providers.tf        # Provider configuration
├── variables.tf        # Variable definitions
└── config/            
    ├── dev.tfvars     # Development variables
    └── prod.tfvars    # Production variables
```

## Prerequisites

- Azure subscription
- Terraform 1.12.2 or later
- Azure CLI
- Appropriate permissions to create network resources

## Configuration

### Required Variables

```hcl
environment            = "dev"
location              = "eastus"
vnet_address_space    = ["10.0.0.0/16"]
app_subnet_prefix     = "10.0.0.0/24"
db_subnet_prefix      = "10.0.1.0/24"
gateway_subnet_prefix = "10.0.2.0/24"
```

### Private DNS Zones

The following private DNS zones are created:
- `privatelink.blob.core.windows.net`
- `privatelink.vaultcore.azure.net`
- `privatelink.azurewebsites.net`
- `privatelink.database.windows.net`

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

## Outputs

- VNET ID and name
- Subnet IDs
- Resource Group details
- DNS Zone information

## Security Features

- Network isolation through subnet segregation
- Service endpoints for enhanced security
- Resource group lock
- Private DNS zones for internal name resolution

## Best Practices

1. Always review `terraform plan` output before applying
2. Use separate variables files for different environments
3. Test changes in development before production
4. Document any custom network requirements
