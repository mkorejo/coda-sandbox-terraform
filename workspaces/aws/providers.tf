terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.42"
    }
  }

  cloud {
    organization = "muradkorejo"
    workspaces {
      name = "aws"
    }
  }
}

provider "aws" {
  alias  = "use1"
  region = local.region
}
