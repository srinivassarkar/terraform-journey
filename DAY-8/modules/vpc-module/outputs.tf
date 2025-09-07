# These outputs allow other modules/configurations to use our VPC resources
output "vpcs" {
  description = "Map of all created VPCs"
  value = {
    for vpc_name, vpc in aws_vpc.this : vpc_name => {
      id         = vpc.id
      cidr_block = vpc.cidr_block
      arn        = vpc.arn
    }
  }
}

output "subnets" {
  description = "Map of all created subnets"
  value = {
    for subnet_name, subnet in aws_subnet.this : subnet_name => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      vpc_id            = subnet.vpc_id
    }
  }
}

output "internet_gateways" {
  description = "Map of all created Internet Gateways"
  value = {
    for igw_name, igw in aws_internet_gateway.this : igw_name => {
      id     = igw.id
      vpc_id = igw.vpc_id
    }
  }
}

output "nat_gateways" {
  description = "Map of all created NAT Gateways"
  value = {
    for nat_name, nat in aws_nat_gateway.this : nat_name => {
      id        = nat.id
      subnet_id = nat.subnet_id
    }
  }
}

output "route_tables" {
  description = "Map of all created route tables"
  value = {
    for rt_name, rt in aws_route_table.this : rt_name => {
      id     = rt.id
      vpc_id = rt.vpc_id
    }
  }
}

# Filtered outputs for common use cases
output "public_subnets" {
  description = "Map of public subnets only"
  value = {
    for subnet_name, subnet in aws_subnet.this :
    subnet_name => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
    if lookup(var.subnet_parameters[subnet_name], "subnet_type", "private") == "public"
  }
}

output "private_subnets" {
  description = "Map of private subnets only"
  value = {
    for subnet_name, subnet in aws_subnet.this :
    subnet_name => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
    if lookup(var.subnet_parameters[subnet_name], "subnet_type", "private") == "private"
  }
}

#  Convenient list outputs for other modules
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    for subnet_name, subnet in aws_subnet.this : subnet.id
    if lookup(var.subnet_parameters[subnet_name], "subnet_type", "private") == "public"
  ]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = [
    for subnet_name, subnet in aws_subnet.this : subnet.id
    if lookup(var.subnet_parameters[subnet_name], "subnet_type", "private") == "private"
  ]
}

