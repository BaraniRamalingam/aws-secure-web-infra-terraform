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

output "web_instance_id" {
  value = module.ec2_web.instance_id
}

output "web_public_ip" {
  value = module.ec2_web.public_ip
}

output "web_public_url" {
  value = module.ec2_web.public_url
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
