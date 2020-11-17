locals {
  prefix     = "muradkorejo"
  project_id = "totemic-atom-154718"

  primary_region   = "us-west1"
  primary_subnet   = join("-", [local.prefix, "subnet-01"])
  secondary_region = "us-west2"
  secondary_subnet = join("-", [local.prefix, "subnet-02"])

  tags = map(
    "Owner",       "mkorejo@presidio.com",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}