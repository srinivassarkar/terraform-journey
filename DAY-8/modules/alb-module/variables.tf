variable "alb_parameters" {
  description = "ALB configurations"

  type = object({
    name            = string
    subnets         = list(string)
    security_groups = list(string)
    internal        = bool
    tags            = map(string)
  })

}

variable "target_groups" {
  description = "Target group config."

  type = map(object({
    name     = string
    port     = number
    protocol = string
    vpc_id   = string
    health_check = object({
      path                = string
      internal            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })
    tags = map(string)
  }))
}


variable "listeners" {
  description = "Listener configs"
  type = list(object({
    port       = number
    protocol   = string
    default_tg = string
  }))
}

variable "ec2_targets" {
  description = "EC2 instances to attach"
  type = map(object({
    tg_name     = string
    instance_id = string
  }))
  default = {}
}
