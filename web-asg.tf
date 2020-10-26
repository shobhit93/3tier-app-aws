resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.demo.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "web" {
  image_id        = var.ec2_amis
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_sg.id]

  key_name    = aws_key_pair.generated_key.key_name
  name        = "web-lc"

  user_data = <<-EOF
              #!/bin/bash
              # install git/nginx
              yum install -y git gettext nginx
              echo "NETWORKING=yes" >/etc/sysconfig/network
              
              # install node
              curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
              . /.nvm/nvm.sh
              nvm install 6.11.5

              # setup sample app client
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/client
              npm install -g @angular/cli@1.1.0
              npm install
              export HOME=/root
              ng build
              rm /usr/share/nginx/html/*
              cp dist/* /usr/share/nginx/html/
              chown -R nginx:nginx /usr/share/nginx/html
			  export APP_ELB="${aws_elb.app_elb.dns_name}" APP_PORT="80" WEB_PORT="80"
		      envsubst '$${APP_PORT} $${APP_ELB} $${WEB_PORT}' < nginx.conf.template > /etc/nginx/nginx.conf
			  service nginx start

EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  launch_configuration = aws_launch_configuration.web.id
  vpc_zone_identifier = [element(aws_subnet.public.*.id, 0)]

  load_balancers    = [aws_alb.web_alb.id]
  target_group_arns = ["${aws_lb_target_group.web-tg.arn}"]
  health_check_type = "ELB"
  min_size = 1
  max_size = 5

  tags = [{
    key                   = "Name"
    value                 = "web-asg"
    propagate_at_launch   = true
  }]
}

resource "aws_autoscaling_attachment" "demo_asg_attachment" { 
  alb_target_group_arn   = aws_alb_target_group.web-tg.arn
  autoscaling_group_name = aws_autoscaling_group.web.id
}