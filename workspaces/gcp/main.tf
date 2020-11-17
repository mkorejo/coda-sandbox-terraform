module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"

  project_id   = local.gcp_project_id
  network_name = local.prefix
  routing_mode = "GLOBAL"

  subnets = [
    {
      description           = "Primary subnet"
      subnet_name           = join("-", [local.prefix, "subnet-01"])
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = local.primary_region
    # subnet_flow_logs      = "true"
    # subnet_private_access = "true"
    },
    {
      description           = "Secondary subnet"
      subnet_name           = join("-", [local.prefix, "subnet-02"])
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = local.secondary_region
    # subnet_flow_logs      = "true"
    # subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    subnet-01 = [
      {
        range_name    = "subnet-01-secondary-01"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]

    subnet-02 = [
      {
        range_name    = "subnet-01-secondary-01"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]
  }

  routes = [
    {
      name                   = "egress-internet"
      description            = "Route through IGW to internet"
      destination_range      = "0.0.0.0/0"
      tags                   = "egress-internet"
      next_hop_internet      = "true"
    }
  ]
}