locals {
  prefix = "muradkorejo"
  region = "us-east-1"

  tags = map(
    "owner",       "murad.korejo@coda.global",
    "purpose",     "RSI demo",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}