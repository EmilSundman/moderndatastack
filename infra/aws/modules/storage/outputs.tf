output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_instance_id" {
  description = "RDS PostgreSQL instance ID"
  value       = aws_db_instance.main.id
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.main.port
}

output "ecr_webserver_repository_url" {
  description = "ECR repository URL for webserver"
  value       = aws_ecr_repository.webserver.repository_url
}

output "ecr_daemon_repository_url" {
  description = "ECR repository URL for daemon"
  value       = aws_ecr_repository.daemon.repository_url
}

output "ecr_dbt_repository_url" {
  description = "ECR repository URL for DBT code location"
  value       = aws_ecr_repository.code-location-dbt.repository_url
}


