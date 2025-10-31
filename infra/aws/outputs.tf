output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.compute.ec2_instance_id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.compute.ec2_instance_public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.compute.ec2_instance_private_ip
}

output "elastic_ip" {
  description = "The Elastic IP address of the EC2 instance (if created)"
  value       = module.compute.elastic_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.networking.main_subnet_id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.networking.ec2_security_group_id
}

output "key_pair_name" {
  description = "The name of the key pair"
  value       = module.compute.key_pair_name
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -o StrictHostKeyChecking=no  -i ~/.ssh/${module.compute.key_pair_name} ubuntu@${module.compute.elastic_ip}"
}

# PostgreSQL RDS outputs
output "database_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.storage.rds_endpoint
}

output "database_port" {
  description = "The port on which the database accepts connections"
  value       = module.storage.rds_port
}

output "database_name" {
  description = "The name of the database"
  value       = var.postgres_db_name
}

output "database_username" {
  description = "The master username for the database"
  value       = var.postgres_username
}

output "database_connection_string" {
  description = "PostgreSQL connection string (password must be provided separately)"
  value       = "postgresql://${var.postgres_username}@${module.storage.rds_endpoint}:${module.storage.rds_port}/${var.postgres_db_name}"
  sensitive   = true
}

# ECR Repository outputs
output "ecr_webserver_repository_url" {
  description = "URL of the webserver ECR repository"
  value       = module.storage.ecr_webserver_repository_url
}

output "ecr_daemon_repository_url" {
  description = "URL of the daemon ECR repository"
  value       = module.storage.ecr_daemon_repository_url
}

output "ecr_code_location_dbt_repository_url" {
  description = "URL of the code location dbt ECR repository"
  value       = module.storage.ecr_dbt_repository_url
}

output "ecr_login_command" {
  description = "Command to authenticate Docker with ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.storage.ecr_webserver_repository_url}"
}

# Additional outputs for deployment script
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.compute.elastic_ip
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.storage.rds_endpoint
} 