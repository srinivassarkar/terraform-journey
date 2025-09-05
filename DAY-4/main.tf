data "aws_availability_zones" "available" {
  state = "available"
}

#VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.vpc_name}-vpc"
  }

}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}



#public subnet 

resource "aws_subnet" "public" {
  count             = length(var.availablity_zones)
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availablity_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
    type = "Public"
  }
}

#private subnet

resource "aws_subnet" "private" {
  count             = length(var.availablity_zones)
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availablity_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
    type = "Private"
  }

}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.availablity_zones)

  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.vpc_name}-eip-${count.index + 1}"
  }
}



#elastic ip for NAT

resource "aws_nat_gateway" "nat_gw" {

  count         = length(var.availablity_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#RT 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.availablity_zones)
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt-${count.index + 1}"
  }
}

# Associate public subnets with public route table

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}
# Associate public subnets with private route table

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id

}




# VPC Peering support (optional - for future use)
# Uncomment if you need VPC peering
# resource "aws_vpc_peering_connection" "peer" {
#   peer_vpc_id = var.peer_vpc_id
#   vpc_id      = aws_vpc.custom_vpc
#   auto_accept = true

#   tags = {
#     Name = "${var.vpc_name}-peering"
#   }
# }
