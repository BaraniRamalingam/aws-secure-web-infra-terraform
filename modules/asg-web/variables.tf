variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ASG instances will run"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the Auto Scaling Group (at least 2 AZs recommended)"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID of the ALB (only this SG can reach instances on port 80)"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN to register ASG instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ASG instances"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}
