#########################
########## VPC ##########
#########################

# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.32.0
module "sandbox_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.57.0"

  name = local.prefix
  cidr = "10.0.0.0/16"
  tags = local.tags

  private_subnet_tags = {
    "kubernetes.io/cluster/muradkorejo-eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
  public_subnet_tags  = {
    "kubernetes.io/cluster/muradkorejo-eks" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  azs             = ["us-east-1c", "us-east-1d", "us-east-1f"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_s3_endpoint   = true
}

#########################
########## EKS ##########
#########################

module "sandbox_eks" {
  count  = 0
  source = "../../modules/eks"

  prefix = local.prefix
  tags   = local.tags

  vpc_id     = module.sandbox_vpc.vpc_id
  subnet_ids = concat(module.sandbox_vpc.private_subnets, module.sandbox_vpc.public_subnets)

  aws_account_id           = var.aws_account_id
  node_group_scale_desired = "3"
  node_group_scale_max     = "5"
  node_group_scale_min     = "1"
  node_group_ssh_key       = "muradkorejo"
}

#########################
###### PostgreSQL #######
#########################



#########################
###### Rancher IAM ######
#########################

module "rancher_iam" {
  source = "../../modules/terraform-aws-rancher-iam"

  tags = local.tags
}
