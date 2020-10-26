# security group for application load balancer
resource "aws_security_group" "app_alb_sg" {
  name        = "app-alb-sg"
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
    Name = "app-alb-security-group"
  }
}

resource "aws_elb" "app_elb" {
  name            = "app-elb"
  security_groups = [aws_security_group.app_alb_sg.id]
  subnets         = aws_subnet.public.*.id

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
  tags = {
    Name = "app-elb"
  }
}

resource "aws_lb_target_group" "app-tg" {
  name     = "app-elb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo.id
  health_check {
    path = "/"
    port = 80
  }
}

# listener
resource "aws_elb_listener" "app_http_listener" {
  load_balancer_arn = aws_elb.app_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_elb_target_group.app-tg.arn
    type             = "forward"
  }
}