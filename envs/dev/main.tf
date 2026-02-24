provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix         = var.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  azs                 = var.azs
}

module "ec2_web" {
  source = "../../modules/ec2-web"

  name_prefix = var.name_prefix

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  instance_type     = "t2.micro"
  allowed_http_cidr = "0.0.0.0/0"
}
