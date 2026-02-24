variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB (must be in at least 2 AZs)"
  type        = list(string)
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to access the ALB over HTTP (80). Use your IP/32 for tighter security."
  type        = string
  default     = "0.0.0.0/0"
}

variable "target_instance_id" {
  description = "EC2 instance ID to register in the ALB target group"
  type        = string
}
