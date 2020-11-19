locals {
  prefix = "mkorejo-sandbox"
  region = "us-east-1"

  my_ip = "72.204.149.59/32"

  tags = map(
    "owner",       "murad.korejo@coda.global",
    "purpose",     "RSI demo",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}