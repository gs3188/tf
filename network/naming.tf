# Network Layer Naming Convention

locals {
  name_prefix = "${var.environment}-network"
  
  tags = {
    Environment = var.environment
    Layer      = "network"
    ManagedBy  = "terraform"
  }
}
