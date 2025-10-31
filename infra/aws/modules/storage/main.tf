# DB subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = [var.main_subnet_id, var.secondary_subnet_id]

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# RDS PostgreSQL instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  # Engine configuration
  engine         = "postgres"
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class

  # Storage configuration
  allocated_storage     = var.postgres_allocated_storage
  max_allocated_storage = var.postgres_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  db_name  = var.postgres_db_name
  username = var.postgres_username
  password = var.postgres_password

  # Network configuration
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Backup configuration
  backup_retention_period = var.postgres_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Performance insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}

# ECR repositories for Docker images
resource "aws_ecr_repository" "webserver" {
  name                 = "${var.project_name}-${var.environment}-webserver"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-webserver"
  }
}

resource "aws_ecr_repository" "daemon" {
  name                 = "${var.project_name}-${var.environment}-daemon"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-daemon"
  }
}

resource "aws_ecr_repository" "code-location-dbt" {
  name                 = "${var.project_name}-${var.environment}-code-location-dbt"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-code-location-dbt"
  }
}

# ECR lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "webserver" {
  repository = aws_ecr_repository.webserver.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 250 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 250
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "daemon" {
  repository = aws_ecr_repository.daemon.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 250 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 250
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "code-location-dbt" {
  repository = aws_ecr_repository.code-location-dbt.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 250 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 250
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
