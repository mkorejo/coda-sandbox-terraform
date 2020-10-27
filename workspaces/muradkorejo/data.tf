data "aws_db_instance" "psql" {
  db_instance_identifier = join("-", [local.prefix, "psql"])
}