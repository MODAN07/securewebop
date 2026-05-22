output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_eip.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions OIDC role"
  value       = aws_iam_role.github_actions.arn
}

output "app_url" {
  description = "URL to access the deployed web application"
  value       = "http://${aws_eip.web.public_ip}"
}
