locals {
  prefix     = "muradkorejo"
  project_id = "totemic-atom-154718"

  primary_region   = "us-west1"
  secondary_region = "us-west2"

  tags = map(
    "Owner",       "mkorejo@presidio.com",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}