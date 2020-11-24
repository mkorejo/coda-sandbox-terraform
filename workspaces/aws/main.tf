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
#### Security Groups ####
#########################

resource "aws_security_group" "allow_all_outgoing" {
  name        = join("-", [local.prefix, "allow-all-outgoing"])
  description = "Allow all outgoing communication"
  tags        = merge(local.tags, {"Name" = join("-", [local.prefix, "allow-all-outgoing"])})
  vpc_id      = module.sandbox_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_rdp" {
  name        = join("-", [local.prefix, "allow-rdp"])
  description = "Allow RDP"
  tags        = merge(local.tags, {"Name" = join("-", [local.prefix, "allow-rdp"])})
  vpc_id      = module.sandbox_vpc.vpc_id
}

resource "aws_security_group" "allow_ssh" {
  name        = join("-", [local.prefix, "allow-ssh"])
  description = "Allow SSH"
  tags        = merge(local.tags, {"Name" = join("-", [local.prefix, "allow-ssh"])})
  vpc_id      = module.sandbox_vpc.vpc_id
}

resource "aws_security_group" "allow_web" {
  name        = join("-", [local.prefix, "allow-web"])
  description = "Allow HTTP/HTTPS"
  tags        = merge(local.tags, {"Name" = join("-", [local.prefix, "allow-web"])})
  vpc_id      = module.sandbox_vpc.vpc_id
}

resource "aws_security_group" "rke_nodes" {
  name        = join("-", [local.prefix, "rke-nodes"])
  description = "Allow all inbound communication from RKE nodes"
  tags        = merge(local.tags, {"Name" = join("-", [local.prefix, "rke-nodes"])})
  vpc_id      = module.sandbox_vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }
}

resource "aws_security_group_rule" "allow_rdp" {
  security_group_id = aws_security_group.allow_rdp.id
  description       = "Inbound on TCP/3389"
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [local.my_ip]
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  description       = "Inbound on TCP/22"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_ip]
}

resource "aws_security_group_rule" "allow_web" {
  for_each = toset([
    "80",
    "443",
    "6443"
  ])

  security_group_id = aws_security_group.allow_web.id
  description       = join("", ["Inbound on TCP/", each.value])
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

#########################
########## EC2 ##########
#########################

resource "aws_instance" "rke_nodes" {
  for_each = toset([
    "rke-control-plane-1",
    "rke-worker-1",
    "rke-worker-2"
  ])

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = "muradkorejo"
  subnet_id                   = module.sandbox_vpc.public_subnets[0]
  tags                        = merge(local.tags, {"Name" = join("-", [local.prefix, each.value])})
  volume_tags                 = merge(local.tags, {"Name" = join("-", [local.prefix, each.value])})
  vpc_security_group_ids      = [
    aws_security_group.allow_all_outgoing.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_web.id,
    aws_security_group.rke_nodes.id
  ]

  root_block_device {
    volume_size = 50
  }
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
