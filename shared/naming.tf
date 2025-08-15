# Shared Layer Naming Convention

locals {
  name_prefix = "${var.environment}-shared"
  
  tags = {
    Environment = var.environment
    Layer      = "shared"
    ManagedBy  = "terraform"
  }
}
