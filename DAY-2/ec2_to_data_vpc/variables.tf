variable "instance_type" {
  type    = string
  default = "t2.micro"

}
variable "key_name" {
  type        = string
  description = "AWS key"

}
variable "ami_id" {
  type        = string
  description = "AMI ID for the instance."
}