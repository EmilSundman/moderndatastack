# AWS Infrastructure Modules

This directory contains modularized Terraform configurations for the Composia platform infrastructure.

## Module Structure

### 1. Networking Module (`./networking/`)

**Purpose**: Manages VPC, subnets, route tables, internet gateway, and security groups.

**Resources**:
- VPC with DNS support
- Public subnets in multiple availability zones
- Internet gateway and route table
- Security groups for EC2 and RDS

**Key Outputs**:
- `vpc_id` - VPC identifier
- `main_subnet_id` - Primary subnet ID
- `secondary_subnet_id` - Secondary subnet ID
- `ec2_security_group_id` - Security group for EC2 instances
- `rds_security_group_id` - Security group for RDS instances

### 2. Compute Module (`./compute/`)

**Purpose**: Manages EC2 instances, IAM roles, policies, and key pairs.

**Resources**:
- Ubuntu 22.04 EC2 instance
- IAM role with ECR and CloudWatch policies
- SSH key pair
- Optional Elastic IP

**Key Outputs**:
- `ec2_instance_id` - EC2 instance identifier
- `ec2_instance_public_ip` - Public IP address
- `ec2_instance_private_ip` - Private IP address
- `elastic_ip` - Elastic IP if created

### 3. Storage Module (`./storage/`)

**Purpose**: Manages RDS PostgreSQL and ECR repositories.

**Resources**:
- RDS PostgreSQL instance with encryption
- ECR repositories for webserver, daemon, and DBT
- Lifecycle policies for image retention

**Key Outputs**:
- `rds_endpoint` - Database connection endpoint
- `ecr_webserver_repository_url` - Webserver ECR repository URL
- `ecr_daemon_repository_url` - Daemon ECR repository URL
- `ecr_dbt_repository_url` - DBT code location ECR repository URL

## Module Dependencies

```
networking → storage → compute
```

- **Networking** must be created first (provides VPC, subnets, security groups)
- **Storage** depends on networking (uses subnets and security groups)
- **Compute** depends on both networking and storage (uses subnets, security groups, and RDS endpoint)

## Usage

The main `main.tf` file orchestrates these modules:

```hcl
module "networking" {
  source = "./modules/networking"
  # ... variables
}

module "storage" {
  source = "./modules/storage"
  # ... variables
  depends_on = [module.networking]
}

module "compute" {
  source = "./modules/compute"
  # ... variables
  depends_on = [module.networking, module.storage]
}
```

## Benefits of This Structure

1. **Reusability**: Modules can be reused across different environments
2. **Maintainability**: Clear separation of concerns
3. **Testability**: Individual modules can be tested in isolation
4. **Scalability**: Easy to add new modules or modify existing ones
5. **Team Collaboration**: Different teams can work on different modules

## Adding New Modules

To add a new module:

1. Create a new directory under `./modules/`
2. Include `main.tf`, `variables.tf`, and `outputs.tf`
3. Update the main `main.tf` to call the new module
4. Update `outputs.tf` to expose new module outputs
5. Document the module in this README

## Module Variables

Each module defines its own variables in `variables.tf`. Common variables like `project_name` and `environment` are passed through from the root module.

## Module Outputs

Module outputs are used to pass data between modules and to the root module's outputs. This creates a clean interface between modules while maintaining loose coupling.
