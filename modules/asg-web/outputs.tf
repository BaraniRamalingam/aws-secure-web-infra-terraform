output "asg_name" {
  value       = aws_autoscaling_group.this.name
  description = "ASG name"
}

output "web_sg_id" {
  value       = aws_security_group.web.id
  description = "Web ASG security group id"
}
