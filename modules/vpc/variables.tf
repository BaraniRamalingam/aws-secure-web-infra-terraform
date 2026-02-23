variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones for public subnets"
  type        = list(string)
}
