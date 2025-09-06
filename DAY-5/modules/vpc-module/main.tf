
# Instead of: count = 2 (creates list: [0], [1])
# We use: for_each = var.vpc_parameters (creates map: {"vpc-name" = {...}})
# Benefits: 
# - Resources have meaningful names/keys
# - Adding/removing items doesn't shift indices
# - More predictable resource addressing
resource "aws_vpc" "this" {
  for_each             = var.vpc_parameters
  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support

  tags = merge(each.value.tags, {
    Name = each.key
  })
}

# Challenge: How do subnets find their VPC when both use for_each?
# Solution: vpc_name in subnet config points to VPC key
resource "aws_subnet" "this" {
  for_each                = var.subnet_parameters
  vpc_id                  = aws_vpc.this[each.value.vpc_name].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = lookup(each.value, "map_public_ip_on_launch", false)

  tags = merge(each.value.tags, {
    Name = each.key
    Type = lookup(each.value, "subnet_type", "private")
  })


}


resource "aws_internet_gateway" "this" {
  for_each = var.igw_parameters
  vpc_id   = aws_vpc.this[each.value.vpc_name].id

  tags = merge(each.value.tags, {
    Name = each.key
  })

}


#elastic ip for NAT

resource "aws_eip" "nat" {
  for_each = var.nat_parameters
  domain   = "vpc"


  # Dependency management - EIP needs IGW to exist first
  depends_on = [aws_internet_gateway.this]

  tags = merge(each.value.tags, {
    Name = "${each.key}-eip"
  })

}

resource "aws_nat_gateway" "this" {
  for_each = var.nat_parameters

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[each.value.subnet_name].id # Must be public subnet

  tags = merge(each.value.tags, {
    Name = each.key
  })

  depends_on = [aws_internet_gateway.this]

}

# dynamic blocks allow us to create nested configurations programmatically
resource "aws_route_table" "this" {
  for_each = var.rt_parameters
  vpc_id   = aws_vpc.this[each.value.vpc_name].id

  tags = merge(each.value.tags, {
    Name = each.key
  })

  # For each route in the routes list, create a route block
  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block = route.value.cidr_block

      # If use_igw is true, reference IGW resource, otherwise use provided ID
      gateway_id     = route.value.use_igw ? aws_internet_gateway.this[route.value.gateway_id].id : null
      nat_gateway_id = route.value.use_nat ? aws_nat_gateway.this[route.value.gateway_id].id : null

      # Note: Only one of gateway_id or nat_gateway_id should be set per route
    }
  }
}

#association mapping
resource "aws_route_table_association" "this" {
  for_each       = var.rt_association_parameters
  subnet_id      = aws_subnet.this[each.value.subnet_name].id
  route_table_id = aws_route_table.this[each.value.rt_name].id
}
