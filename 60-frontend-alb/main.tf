resource "aws_lb" "public_alb" {
  name               = "${local.common_name}-public-alb" # roboshop-dev-public-alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.public_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false # usuaully true, but while practicing make it false

  tags = merge(
    {
      Name = "${local.common_name}-public-alb"
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, I am from HTTPS public ALB</h1>"
      status_code  = "200"
    }
  }
}


# 1. Create the ALB Target Group
resource "aws_lb_target_group" "app1" {
  name        = "app1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip" # Can be: instance, ip, lambda, or alb

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "app1" {
  listener_arn = aws_lb_listener.https.arn # Links to an existing listener
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1.arn
  }

  condition {
    host_header {
      values = ["app1-${var.environment}.${var.domain_name}"] # app1-dev.daws90s.shop
    }
  }
}

resource "aws_lb_target_group" "app2" {
  name        = "app2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip" # Can be: instance, ip, lambda, or alb

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "app2" {
  listener_arn = aws_lb_listener.https.arn # Links to an existing listener
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app2.arn
  }

  condition {
    host_header {
      values = ["app2-${var.environment}.${var.domain_name}"] # app1-dev.daws90s.shop
    }
  }
}