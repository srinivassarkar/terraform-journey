provider "aws" {
  region = "us-east-1"

}
#vpc
# Method 3: Find VPC by CIDR block
data "aws_vpc" "existing" {
  filter {
    name   = "cidr"
    values = ["10.0.0.0/16"]
  }
}


#get all subnets and filter 
data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  # filter {
  #   name   = "availability-zone"
  #   values = ["us-east-1a"]
  # }
  # Optional: Ensure we get public subnets only
  # filter {
  #   name   = "map-public-ip-on-launch"
  #   values = ["true"]
  # }
}
#get subnet - one subnet
data "aws_subnet" "public" {
  id = data.aws_subnets.all_subnets.ids[0]
}


#get SG
# data "aws_security_group" "existing" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing.id]
#   }

#    filter {
#     name   = "group-id"
#     values = ["sg-08c19526f2c67b77d"]
#   }
# }

# # Get the latest AMI dynamically 
# data "aws_ami" "ubuntu_latest" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

resource "aws_instance" "public_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.public.id
  #vpc_security_group_ids      = [data.aws_security_group.existing.id]
  vpc_security_group_ids      = ["sg-05641685084f62b40"]
  associate_public_ip_address = true



  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install nginx -y
    systemctl enable nginx
    systemctl start nginx
    rm -f /var/www/html/index.nginx-debian.html
    cat > /var/www/html/index.html <<HTML
    <h1>Welcome to Terraform, Day-2!</h1>
    <h2>Thanks for paying attention to this matter</h2>
    <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    HTML
  EOF

  tags = {
    Name = "Day2-Public-EC2"
  }
}



# Debugging outputs
# output "all_subnet_ids" {
#   value = data.aws_subnets.all_subnets.ids
# }

# output "sg_id" {
#   value = data.aws_security_group.existing.id
# }