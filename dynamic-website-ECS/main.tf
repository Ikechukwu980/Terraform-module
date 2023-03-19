# configure aws provider 
provider "aws" {
  region  = var.region
  profile = "mainuser"

}

# create vpc
module "vpc" {
  source                       = "../module/vpc"
  region                       = var.region
  project_name                 = var.project_name
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr

}

#create nat gateway 
module "nat_gateway" {
  source                     = "../module/NAT-gateway"
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  internet_gateway           = module.vpc.internet_gateway
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id 
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id

}

# create security groups
module "security_group" {
  source = "../module/security-groups"
  vpc_id = module.vpc.vpc_id
}

# create ECS task execution role
module "ecs_task_execution_role" {
  source       = "../module/ECS-task-execution-role"
  project_name = module.vpc.project_name
}

# creating an SSL certificate
module "ACM" {
  source = "../module/aws-acm"
  domain_name = var.domain_name
  alternative_name =  var.alternative_name
}

# create an application load balancer
module "application_load_balancer" {
  source = "../module/ALB"
  project_name           = module.vpc.project_name 
  alb_security_group_id  = module.security_group.alb_security_group_id
  public_subnet_az1_id   = module.vpc.public_subnet_az1_id
  public_subnet_az2_id   = module.vpc.public_subnet_az2_id 
  vpc_id                 = module.vpc.vpc_id
  certificate_arn        = module.ACM.certificate_arn
}