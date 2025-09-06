resource "aws_security_group" "this" {
  for_each = var.sg_parameters

  name        = each.key
  vpc_id      = each.value.vpc_id
  description = "Terraform SG"

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      protocol   = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block

    }

  }
  dynamic "egress" {
    for_each = each.value.egress

    content {
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
      protocol   = egress.value.protocol
      cidr_blocks = egress.value.cidr_block

    }

  }
  tags = each.value.tags

}


resource "aws_instance" "this" {
  for_each = var.ec2_parameters

  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [
    aws_security_group.this[each.value.sg_name].id
  ]

  key_name = try(each.value.key_name, null) # <-- safely optional
  tags     = each.value.tags

}
