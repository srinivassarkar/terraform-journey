variable "ec2_parameters" {
  description = "Map of EC2 instance config"

  type = map(object({
    ami           = string
    instance_type = string
    subnet_id     = string
    sg_name       = string
    key_name      = optional(string)
    tags          = map(string)

  }))

  default = {}


}


variable "sg_parameters" {
  description = "Map for Security Groups"

  type = map(object({
    vpc_id = string
    ingress = list(object({
      from_port  = number
      to_port    = number
      protocol   = string
      cidr_block = list(string)
    }))
    egress = list(object({
      from_port  = number
      to_port    = number
      protocol   = string
      cidr_block = list(string)
    }))
    tags = map(string)
  }))
  default = {}

}
