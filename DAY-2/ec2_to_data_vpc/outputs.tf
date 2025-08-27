output "infrastructure_summary" {
  description = "Summary of discovered infrastructure"
  value = {
    vpc_id              = data.aws_vpc.existing.id
    vpc_cidr            = data.aws_vpc.existing.cidr_block
    subnet_id           = data.aws_subnet.public.id
    availability_zone   = data.aws_subnet.public.availability_zone
    #security_group_id   = data.aws_security_group.existing.id
    #security_group_name = data.aws_security_group.existing.name
    total_subnets_found = length(data.aws_subnets.all_subnets.ids)
  }
}