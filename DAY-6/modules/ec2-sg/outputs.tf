output "ec2_ids" {
  value = { for k, inst in aws_instance.this : k => inst.id }
}

output "sg_ids" {
  value = { for k, sg in aws_security_group.this : k => sg.id }
}
