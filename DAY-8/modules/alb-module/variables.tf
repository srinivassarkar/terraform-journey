variable "alb_parameters" {
  description = "ALB configurations"
  type = object({
    name               = string
    load_balancer_type = string
    subnets            = list(string)
    security_groups    = list(string)
    internal           = bool
    tags               = map(string)
  })
}

variable "target_groups" {
  description = "Target group config."
  type = map(object({
    name     = string
    port     = number
    protocol = string
    vpc_id   = string
    health_check = optional(object({ # Made optional
      path                = optional(string, "/")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 5)
      unhealthy_threshold = optional(number, 2)
    }), {})
    tags = optional(map(string), {}) # Made optional
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
