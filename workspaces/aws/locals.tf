locals {
  prefix = "mkorejo-sandbox"
  region = "us-east-1"

  tags = map(
    "owner",       "mkorejo@presidio.com",
    "purpose",     "RSI demo",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}