terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


module "vpc" {
  source = "./modules/vpc-module"

  vpc_parameters = {
    main-vpc = {
      cidr_block           = "10.0.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags                 = { Owner = "Seenu" }
    }
  }

  subnet_parameters = {
    public-1 = {
      vpc_name          = "main-vpc"
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-south-1a"
      subnet_type       = "public"
      tags              = { Tier = "frontend" }
    }
    private-1 = {
      vpc_name          = "main-vpc"
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-south-1b"
      subnet_type       = "private"
      tags              = { Tier = "backend" }
    }
  }

  igw_parameters = {
    igw-main = {
      vpc_name = "main-vpc"
      tags        = { Gateway = "internet" }
    }
  }

  nat_parameters = {
    nat-1 = {
      subnet_name = "public-1"
      tags        = { Gateway = "nat" }
    }
  }

  rt_parameters = {
    public-rt = {
      vpc_name = "main-vpc"
      tags     = { Type = "public" }
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          use_igw    = true
          gateway_id = "igw-main"
        }
      ]
    }
    private-rt = {
      vpc_name = "main-vpc"
      tags     = { Type = "private" }
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          use_nat    = true
          gateway_id = "nat-1"
        }
      ]
    }
  }

  rt_association_parameters = {
    public-1-assoc = {
      subnet_name = "public-1"
      rt_name     = "public-rt"
    }
    private-1-assoc = {
      subnet_name = "private-1"
      rt_name     = "private-rt"
    }
  }
}
