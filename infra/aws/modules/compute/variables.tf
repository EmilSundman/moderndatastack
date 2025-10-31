variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group for the EC2 instance"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}

variable "ssh_public_key" {
  description = "Public SSH key for EC2 instance access"
  type        = string
}



variable "postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  type        = string
}

variable "postgres_username" {
  description = "RDS PostgreSQL username"
  type        = string
}

variable "postgres_password" {
  description = "RDS PostgreSQL password"
  type        = string
}

variable "postgres_db_name" {
  description = "RDS PostgreSQL database name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "main_subnet_id" {
  description = "ID of the main subnet for RDS"
  type        = string
}

variable "secondary_subnet_id" {
  description = "ID of the secondary subnet for RDS"
  type        = string
}