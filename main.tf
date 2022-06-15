# data sources
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Type = "Public"
  }
}
data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.id)
  id       = each.value
}
# gateway load balancer
resource "aws_lb" "gateway" {
  name_prefix        = "gateway-"
  load_balancer_type = "gateway"

  subnets = [for subnet in data.aws_subnet.public : subnet.id]

  tags = {
    Name = "gateway-loadbalancer"
  }
}

resource "aws_lb_listener" "gateway" {
  load_balancer_arn = aws_lb.gateway.arn

  default_action {
    target_group_arn = aws.aws_lb_target_group.gateway.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "gateway" {
  name_prefix = "gateway-"
  port        = 6081
  protocol    = "GENEVE"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    port     = 80
    protocol = "TCP"
  }
  tags = {
    Name = "gateway-tg"
  }
}

# gateway endpoint
resource "aws_vpc_endpoint_service" "gateway" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gateway.arn]
  tags = {
    Name = "egress-gateway-endpoint"
  }
}
# gateway nodes
resource "aws_lb_target_group_attachment" "gateway" {
  target_group_arn = aws_lb_target_group.gateway.arn
  target_id        = aws_instance.gateway.id
}
# gateway security groups
