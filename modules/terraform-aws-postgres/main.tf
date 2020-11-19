resource "aws_security_group" "allow_postgres" {
  name        = join("-", [var.prefix, "allow-psql"])
  description = "Security group for RDS PostgreSQL instances"
  vpc_id      = module.sandbox_vpc.vpc_id

  ingress {
    description = "TCP/5432 for database connections"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat(module.sandbox_vpc.private_subnets_cidr_blocks, module.sandbox_vpc.public_subnets_cidr_blocks)
  }
}

resource "aws_db_subnet_group" "sandbox_rds" {
  name       = var.prefix
  subnet_ids = module.sandbox_vpc.private_subnets
  tags       = var.tags
}

resource "aws_db_instance" "sandbox_rds" {
  allocated_storage         = 20
  copy_tags_to_snapshot     = true
  db_subnet_group_name      = aws_db_subnet_group.sandbox_rds.id
  engine                    = "postgres"
  engine_version            = "12"
  final_snapshot_identifier = var.prefix
  identifier                = join("-", [var.prefix, "psql"])
  instance_class            = "db.t2.small"
  username                  = var.rds_master_username
  password                  = var.rds_master_password
  skip_final_snapshot       = var.rds_skip_final_snapshot
  storage_type              = "gp2"
  tags                      = var.tags
  vpc_security_group_ids    = [ aws_security_group.allow_postgres.id ]
}

variable "prefix" {}
variable "tags" {}