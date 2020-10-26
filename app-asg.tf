# security group for EC2 instances
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
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

resource "aws_launch_configuration" "app" {
  image_id        = var.ec2_amis
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.app_sg.id]

  #TODO REMOVE
  key_name    = aws_key_pair.generated_key.key_name
  name        = "app-lc"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y java-1.8.0-openjdk-devel wget git
              export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0
              wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
              sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
              yum install -y apache-maven
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/server
			  nohup mvn spring-boot:run -Dspring.datasource.url=jdbc:postgresql://"${aws_db_instance.rds.endpoint}:${var.db_port}/${var.rds_username}" -Dspring.datasource.username="${var.rds_username}" -Dspring.datasource.password="${var.rds_password}" -Dserver.port="80" &> mvn.out &
EOF


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  launch_configuration = aws_launch_configuration.app.id
  vpc_zone_identifier = [element(aws_subnet.private.*.id, 0)]

  load_balancers    = [aws_elb.app_elb.id]
  target_group_arns = ["${aws_lb_target_group.app-tg.arn}"]
  health_check_type = "ELB"

  min_size = 1
  max_size = 5

  tags = [{
    key                   = "Name"
    value                 = "app-asg"
    propagate_at_launch   = true
  }]
}
