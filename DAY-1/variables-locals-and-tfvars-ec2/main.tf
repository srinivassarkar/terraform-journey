provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "ubuntu_server" {
  name        = "nginx-server_1"
  description = "security group for nginx server"
  vpc_id      = var.vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "ubuntu_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ubuntu_server.id]
  associate_public_ip_address = true



  user_data = <<-EOF
#!/bin/bash
apt-get update -y
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx
rm -f /var/www/html/index.nginx-debian.html
cat > /var/www/html/index.html <<HTML
<h1>Welcome to Terraform!</h1>
<h2>Thanks for paying attention to this matter</h2>
HTML
EOF


  tags = {
    Name = "ubuntu_server"
  }

}


# terraform taint aws_instance.ubuntu_server
# terraform apply -auto-approve

# 👉 Only the EC2 instance will be destroyed/recreated, SG and VPC untouched.

# If you want it quick (no reapply) → SSH in and run the script manually.

# error happened because you left networking “implicit.” AWS doesn’t guess right; it falls back to default VPC. Solution is always: explicitly wire VPC → Subnet → SG → Instance.