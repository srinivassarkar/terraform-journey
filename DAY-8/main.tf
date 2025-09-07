terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "./modules/vpc-module"

  vpc_parameters = {
    web-vpc = {
      cidr_block           = "10.0.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags                 = { Name = "web-vpc" }
    }
  }

  subnet_parameters = {
    public-1 = {
      vpc_name                = "web-vpc"
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      subnet_type             = "public"
      map_public_ip_on_launch = true
      tags                    = { Name = "public-1" }
    }
    public-2 = {
      vpc_name                = "web-vpc"
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-east-1b"
      subnet_type             = "public"
      map_public_ip_on_launch = true
      tags                    = { Name = "public-2" }
    }
  }

  igw_parameters = {
    igw-web = {
      vpc_name = "web-vpc"
      tags     = { Name = "igw-web" }
    }
  }

  rt_parameters = {
    public-rt = {
      vpc_name = "web-vpc"
      tags     = { Name = "public-rt" }
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          use_igw    = true
          gateway_id = "igw-web"
        }
      ]
    }
  }

  rt_association_parameters = {
    public-1-assoc = {
      subnet_name = "public-1"
      rt_name     = "public-rt"
    }
    public-2-assoc = {
      subnet_name = "public-2"
      rt_name     = "public-rt"
    }
  }
}


module "ec2_sg" {
  source = "./modules/ec2-sg-module"

  sg_parameters = {
    web-sg = {
      vpc_id = module.vpc.vpcs["web-vpc"].id
      ingress = [
        { from_port = 22, to_port = 22, protocol = "tcp", cidr_block = ["0.0.0.0/0"] },
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = ["0.0.0.0/0"] }
      ]
      egress = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_block = ["0.0.0.0/0"] }
      ]
      tags = { Name = "web-sg" }
    }
  }

  ec2_parameters = {
    web-server-1 = {
      ami                 = "ami-0360c520857e3138f"
      instance_type       = "t2.micro"
      subnet_id           = module.vpc.subnets["public-1"].id
      sg_name             = "web-sg"
      associate_public_ip = true
      user_data           = <<-EOF
              #!/bin/bash
              set -xe
              # Retry update until success (handles slow boot/network issues)
              until apt-get update -y; do
                echo "Retrying apt-get update..."
                sleep 5
              done
              # Install Nginx
              apt-get install -y nginx
              # Enable + start nginx
              systemctl enable nginx
              systemctl start nginx
              # Replace default page
              echo "<h1>Hostname is $(hostname)</h1>" > /var/www/html/index.html
              chown -R www-data:www-data /var/www/html
              chmod -R 755 /var/www/html
              EOF

      key_name = "vpc-handson"
      tags     = { Name = "web-server-1" }
    }
    web-server-2 = {
      ami                 = "ami-0360c520857e3138f"
      instance_type       = "t2.micro"
      subnet_id           = module.vpc.subnets["public-2"].id
      sg_name             = "web-sg"
      associate_public_ip = true
      user_data           = <<-EOF
              #!/bin/bash
              set -xe
              # Retry update until success (handles slow boot/network issues)
              until apt-get update -y; do
                echo "Retrying apt-get update..."
                sleep 5
              done
              # Install Nginx
              apt-get install -y nginx
              # Enable + start nginx
              systemctl enable nginx
              systemctl start nginx
              # Replace default page
              echo "<h1>Hostname is $(hostname)</h1>" > /var/www/html/index.html
              chown -R www-data:www-data /var/www/html
              chmod -R 755 /var/www/html
              EOF
      key_name            = "vpc-handson"
      tags                = { Name = "web-server-2" }
    }
  }
}


module "alb" {
  source = "./modules/alb-module"

  alb_parameters = {
    name               = "web-alb"
    load_balancer_type = "application"
    subnets            = [module.vpc.subnets["public-1"].id, module.vpc.subnets["public-2"].id]
    security_groups    = [module.ec2_sg.sg_ids["web-sg"]]
    internal           = false
    tags               = { Name = "web-alb" }
  }

  target_groups = {
    web-tg = {
      name     = "web-target-group"
      port     = 80
      protocol = "HTTP"
      vpc_id   = module.vpc.vpcs["web-vpc"].id
      health_check = {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
      tags = { Name = "web-tg" }
    }
  }

  listeners = [
    {
      port       = 80
      protocol   = "HTTP"
      default_tg = "web-tg"
    }
  ]

  ec2_targets = {
    web-server-1 = {
      tg_name     = "web-tg"
      instance_id = module.ec2_sg.ec2_ids["web-server-1"]
    }
    web-server-2 = {
      tg_name     = "web-tg"
      instance_id = module.ec2_sg.ec2_ids["web-server-2"]
    }
  }
}
