# Application Layer Naming Convention

locals {
  name_prefix = "${var.environment}-app"
  
  tags = {
    Environment = var.environment
    Layer      = "application"
    ManagedBy  = "terraform"
  }
}
