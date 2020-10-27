provider "aws" {
  version = "3.9.0"
  region  = "us-east-1"
}

provider "postgresql" {
  host     = data.aws_db_instance.psql.host
  username = data.aws_db_instance.psql.username
  password = data.aws_db_instance.psql.password
}