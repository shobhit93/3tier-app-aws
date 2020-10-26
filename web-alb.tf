# security group for application load balancer
resource "aws_security_group" "web_alb_sg" {
  name        = "web-alb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.demo.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-alb-security-group"
  }
}

# using ALB - instances in private subnets
resource "aws_alb" "web_alb" {
  name            = "web-alb-public"
  security_groups = [aws_security_group.web_alb_sg.id]
  subnets         = aws_subnet.public.*.id
  tags = {
    Name = "web-alb"
  }
}

# alb target group
resource "aws_alb_target_group" "web-tg" {
  name     = "web-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo.id
  health_check {
    path = "/"
    port = 80
  }
}

# listener
resource "aws_alb_listener" "web_http_listener" {
  load_balancer_arn = aws_alb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web-tg.arn
    type             = "forward"
  }
}

resource "aws_route53_zone" "main" {
  name = "shobhitprivateroute.com"
}

resource "aws_route53_record" "main" {
  allow_overwrite = true
  name            = "shobhitprivateroute.com"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.main.zone_id

  records = [
    aws_route53_zone.main.name_servers[0],
    aws_route53_zone.main.name_servers[1],
    aws_route53_zone.main.name_servers[2],
    aws_route53_zone.main.name_servers[3],
  ]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.shobhitprivateroute.com"
  type    = "A"
  alias {
    name                   = "dualstack.${aws_alb.web_alb.dns_name}"
    zone_id                = aws_alb.web_alb.zone_id
    evaluate_target_health = false
  }
}