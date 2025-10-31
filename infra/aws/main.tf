terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Note: Backend bucket name cannot use variables directly
    # Override via backend config: terraform init -backend-config="bucket=your-project-name-terraform-state"
    # Or create a backend.hcl file with: bucket = "moderndatastack-terraform-state"
    bucket  = "moderndatastack-terraform-state"
    key     = "terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Locals for AWS Account ID and state bucket - read from variables
locals {
  aws_account_id          = var.aws_account_id
  terraform_state_bucket = var.terraform_state_bucket != null ? var.terraform_state_bucket : "${var.project_name}-terraform-state"
}

# Networking module
module "networking" {
  source = "./modules/networking"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_cidr                    = var.vpc_cidr
  subnet_cidr                 = var.subnet_cidr
  secondary_subnet_cidr       = var.secondary_subnet_cidr
  availability_zone           = var.availability_zone
  secondary_availability_zone = var.secondary_availability_zone
  allowed_ssh_cidr_blocks     = var.allowed_ssh_cidr_blocks
}

# Storage module
module "storage" {
  source = "./modules/storage"

  project_name                     = var.project_name
  environment                      = var.environment
  rds_security_group_id            = module.networking.rds_security_group_id
  postgres_engine_version          = var.postgres_engine_version
  postgres_instance_class          = var.postgres_instance_class
  postgres_allocated_storage       = var.postgres_allocated_storage
  postgres_max_allocated_storage   = var.postgres_max_allocated_storage
  postgres_db_name                 = var.postgres_db_name
  postgres_username                = var.postgres_username
  postgres_password                = var.postgres_password
  postgres_backup_retention_period = var.postgres_backup_retention_period
  main_subnet_id                   = module.networking.main_subnet_id
  secondary_subnet_id              = module.networking.secondary_subnet_id

  depends_on = [module.networking]
}

# Compute module
module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  environment       = var.environment
  instance_type     = var.instance_type
  subnet_id         = module.networking.main_subnet_id
  security_group_id = module.networking.ec2_security_group_id
  root_volume_size  = var.root_volume_size
  ssh_public_key    = var.ssh_public_key

  postgres_endpoint   = module.storage.rds_endpoint
  postgres_username   = var.postgres_username
  postgres_password   = var.postgres_password
  postgres_db_name    = var.postgres_db_name
  aws_region          = var.aws_region
  aws_account_id      = local.aws_account_id
  main_subnet_id      = module.networking.main_subnet_id
  secondary_subnet_id = module.networking.secondary_subnet_id

  depends_on = [module.networking, module.storage]
} 