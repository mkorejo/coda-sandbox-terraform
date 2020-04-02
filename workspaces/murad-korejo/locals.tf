locals {
  prefix = "murad-korejo"
  region = "us-east-1"

  tags = map(
    "Owner",       "Murad Korejo",
    "Owner Email", "murad.korejo@coda.global",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}