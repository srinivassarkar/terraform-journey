#create ALB
resource "aws_lb" "this" {
  name               = var.alb_parameters.name
  load_balancer_type = "application"
  subnets            = var.alb_parameters.subnets
  security_groups    = var.alb_parameters.security_groups
  internal           = var.alb_parameters.internal
  tags               = var.alb_parameters.tags
}

#create Target groups
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = each.key.vpc_id

  health_check {
    path                = each.value.health_check.path
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }

}

#listners
resource "aws_lb_listener" "this" {
  for_each = { for l in var.listeners : l.port => l }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.default_tg].arn
  }
}

#attach ec2
resource "aws_lb_target_group_attachment" "this" {
  for_each = var.ec2_targets

  target_group_arn = aws_lb_target_group.this[each.value.tg_name].arn
  target_id        = each.value.instance_id
  port             = aws_lb_target_group.this[each.value.tg_name].port

}

