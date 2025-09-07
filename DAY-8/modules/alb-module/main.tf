# Create ALB
resource "aws_lb" "this" {
  name               = var.alb_parameters.name
  load_balancer_type = var.alb_parameters.load_balancer_type
  subnets            = var.alb_parameters.subnets
  security_groups    = var.alb_parameters.security_groups
  internal           = var.alb_parameters.internal
  tags               = var.alb_parameters.tags
}

# Create Target Groups
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups
  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = each.value.vpc_id

  health_check {
    path                = try(each.value.health_check.path, "/")
    interval            = try(each.value.health_check.interval, 30)
    timeout             = try(each.value.health_check.timeout, 5)
    healthy_threshold   = try(each.value.health_check.healthy_threshold, 5)
    unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 2)
  }

  tags = try(each.value.tags, {})
}

# Attach EC2s to Target Groups
resource "aws_lb_target_group_attachment" "this" {
  for_each         = var.ec2_targets
  target_group_arn = aws_lb_target_group.this[each.value.tg_name].arn
  target_id        = each.value.instance_id
  port             = aws_lb_target_group.this[each.value.tg_name].port
}

# Listeners
resource "aws_lb_listener" "this" {
  for_each = { for idx, listener in var.listeners : idx => listener }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.default_tg].arn
  }
}
