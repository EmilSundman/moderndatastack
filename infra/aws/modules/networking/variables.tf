variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the main subnet"
  type        = string
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the main subnet"
  type        = string
}

variable "secondary_availability_zone" {
  description = "Availability zone for the secondary subnet"
  type        = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to EC2 instances"
  type        = list(string)
}
