output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "elastic_ip" {
  description = "Elastic IP address of the EC2 instance"
  value       = aws_eip.main.public_ip
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.main.key_name
}
