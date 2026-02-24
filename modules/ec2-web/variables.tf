variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to access HTTP (80)"
  type        = string
  default     = "0.0.0.0/0"
}
