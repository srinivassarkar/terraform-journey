variable "aws_region" {
  type        = string
  description = "AWS region to deploy in."
}
variable "instance_type" {
  type        = string
  description = "AWS instance type."
}
variable "key_name" {
  type        = string
  description = "key pair name to access the instance."
}
variable "ami_id" {
  type        = string
  description = "AMI ID for the instance."
}
variable "vpc_id" {
  type        = string
  description = "VPC ID for the instance."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the instance."

}