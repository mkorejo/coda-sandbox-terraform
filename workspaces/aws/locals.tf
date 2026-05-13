locals {
  prefix = "mkorejo-sandbox"
  region = "us-east-1"

  my_ip = "72.204.149.59/32"

  tags = {
    "owner"      = "mkorejo"
    "purpose"    = "Funsies"
    "Managed By" = "Terraform"
    "Source"     = "https://github.com/mkorejo/coda-sandbox-terraform"
  }
}
