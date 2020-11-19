terraform {
  required_providers {
    postgresql = {
      source   = "terraform-providers/postgresql"
      host     = muradkorejo-psql.cuukwis7t1js.us-east-1.rds.amazonaws.com
      username = "foo"
      password = "foobarbaz"
    }
    required_version = ">= 0.13"
  }
}

resource "postgresql_database" "burpenterprise" {
  name = "burpenterprise"
}

resource "postgresql_role" "burp_enterprise" {
  name     = "burp_enterprise"
  login    = true
  password = "burp"
}

resource "postgresql_role" "burp_agent" {
  name     = "burp_agent"
  login    = true
  password = "burp"
}

resource "postgresql_grant" "burpenterprise_to_burp_enterprise" {
  database    = "burpenterprise"
  role        = "burp_enterprise"
  schema      = "public"
  object_type = "database"
  privileges  = ["SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, CREATE, CONNECT, TEMPORARY, EXECUTE, USAGE"]
}
