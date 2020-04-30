locals {
  prefix = "muradkorejo"
  region = "us-east-1"

  tags = map(
    "Owner",       "murad.korejo@coda.global",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}