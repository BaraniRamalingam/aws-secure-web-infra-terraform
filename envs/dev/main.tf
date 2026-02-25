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

module "alb" {
  source = "../../modules/alb"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids
  allowed_http_cidr = "0.0.0.0/0"

  target_instance_id  = null
  acm_certificate_arn = var.acm_certificate_arn
}

module "asg_web" {
  source = "../../modules/asg-web"

  name_prefix      = var.name_prefix
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  instance_type    = "t2.micro"
  min_size         = 1
  max_size         = 1
  desired_capacity = 1
}
