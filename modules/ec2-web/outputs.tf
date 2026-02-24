output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 of the web server"
  value       = aws_instance.web.public_ip
}

output "public_url" {
  description = "URL to test Nginx"
  value       = "http://${aws_instance.web.public_ip}"
}

output "security_group_id" {
  description = "Security group ID for the web server"
  value       = aws_security_group.web.id
}
