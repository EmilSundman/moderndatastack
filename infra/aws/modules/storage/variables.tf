variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "rds_security_group_id" {
  description = "ID of the RDS security group"
  type        = string
}

variable "postgres_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "postgres_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "postgres_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
}

variable "postgres_max_allocated_storage" {
  description = "Maximum allocated storage for RDS in GB"
  type        = number
}

variable "postgres_db_name" {
  description = "RDS PostgreSQL database name"
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

variable "postgres_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

variable "main_subnet_id" {
  description = "ID of the main subnet for RDS"
  type        = string
}

variable "secondary_subnet_id" {
  description = "ID of the secondary subnet for RDS"
  type        = string
}