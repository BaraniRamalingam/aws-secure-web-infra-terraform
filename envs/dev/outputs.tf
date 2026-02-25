output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.vpc.public_route_table_id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "ALB URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "target_group_arn" {
  description = "Target group ARN for the ALB"
  value       = module.alb.target_group_arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg_web.asg_name
}

output "asg_web_sg_id" {
  description = "Security group ID used by ASG instances"
  value       = module.asg_web.web_sg_id
}

output "app_https_url" {
  description = "HTTPS URL (Route53 -> ALB)"
  value       = "https://terraformproject.baranistack.com"
}
