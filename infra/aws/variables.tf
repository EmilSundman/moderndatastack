variable "aws_account_id" {
  description = "The AWS account ID (can be set via TF_VAR_aws_account_id environment variable or tfvars file)"
  type        = string
  default     = null

  validation {
    condition     = var.aws_account_id != null && var.aws_account_id != ""
    error_message = "AWS Account ID must be set. Set it via: export TF_VAR_aws_account_id=your-account-id or use a tfvars file."
  }
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "The environment to deploy resources to"
  type        = string
  default     = "test"
}

variable "terraform_state_bucket" {
  description = "The name of the S3 bucket to store the Terraform state"
  type        = string
  default     = null
}

variable "project_name" {
  description = "The name of the project, used for resource naming"
  type        = string
  default     = "moderndatastack"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "eu-north-1a"
}

variable "secondary_availability_zone" {
  description = "The availability zone for the secondary subnet"
  type        = string
  default     = "eu-north-1b"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 40
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Warning: This allows SSH from anywhere
}

variable "ssh_public_key" {
  description = "The public SSH key for the key pair"
  type        = string
  sensitive   = true
}

variable "user_data" {
  description = "User data script to run on instance startup"
  type        = string
  default     = ""
}



# PostgreSQL RDS variables
variable "postgres_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "17.5"
}

variable "postgres_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "postgres_max_allocated_storage" {
  description = "Maximum allocated storage in GB for auto-scaling"
  type        = number
  default     = 100
}

variable "postgres_db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "moderndatastack_dagster"
}

variable "postgres_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "Master password for the database"
  type        = string
  default     = "postgres"
}

variable "postgres_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
} 