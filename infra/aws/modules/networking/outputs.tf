output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "main_subnet_id" {
  description = "ID of the main subnet"
  value       = aws_subnet.main.id
}

output "secondary_subnet_id" {
  description = "ID of the secondary subnet"
  value       = aws_subnet.secondary.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "route_table_id" {
  description = "ID of the main route table"
  value       = aws_route_table.main.id
}
