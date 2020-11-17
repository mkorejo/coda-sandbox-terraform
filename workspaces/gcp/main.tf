module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"

  project_id   = local.project_id
  network_name = local.prefix
  routing_mode = "GLOBAL"

  subnets = [
    {
      description           = "Primary subnet"
      subnet_name           = local.primary_subnet
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = local.primary_region
    # subnet_flow_logs      = "true"
    # subnet_private_access = "true"
    },
    {
      description           = "Secondary subnet"
      subnet_name           = local.secondary_subnet
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = local.secondary_region
    # subnet_flow_logs      = "true"
    # subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    local.primary_subnet = [
      {
        range_name    = "subnet-01-secondary-01"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]

    local.secondary_subnet = [
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