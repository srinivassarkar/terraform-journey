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
  source = "../DAY-5/modules/vpc-module"

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
  }
}


module "ec2_sg" {
  source = "./modules/ec2-sg"

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
    web-server = {
      ami                 = "ami-0360c520857e3138f"
      instance_type       = "t2.micro"
      subnet_id           = module.vpc.subnets["public-1"].id
      sg_name             = "web-sg"
      associate_public_ip = true
      user_data           = <<-EOF
                            #!/bin/bash
                            apt-get update -y
                            apt-get install nginx -y
                            systemctl enable nginx
                            systemctl start nginx
                            rm -f /var/www/html/index.nginx-debian.html
                            cat > /var/www/html/index.html <<HTML
                            <h1>Okay; its working via Gitlab and Terraform</h1>
                            <h2>Thanks for paying attention to this matter</h2>
                            HTML
                            chown -R www-data:www-data /var/www/html
                            chmod -R 755 /var/www/html
                            chmod 755 /var/log/nginx
                            chown www-data:www-data /var/log/nginx/error.log
                            systemctl restart nginx
                            EOF
      key_name            = "vpc-handson"
      tags                = { Name = "web-server" }
    }
  }
}


