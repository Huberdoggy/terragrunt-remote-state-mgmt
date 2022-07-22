terraform {
  required_version = ">= 1.2.5, < 2.0.0"
}

provider "aws" {
  region  = var.aws_region
  profile = "development"
}


# Modified to create an Auto Scaling group instead of a single instance
resource "aws_launch_configuration" "Test_ASG" {
  image_id        = "ami-0070c5311b7677678"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data       = <<-EOF
			#!/bin/bash
			echo -e "Kyle, the wizard, execs shell command into index\nAnd spins up web server on port 8080" > index.html
			nohup busybox httpd -fp "${var.server_port}" &
			EOF

  lifecycle {                    # Required meta parameter for ASGs
    create_before_destroy = true # Will wait to rm old EC2 instance until the new one comes up
  }
}

resource "aws_security_group" "instance" {
  name = var.instance_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Sec group for the load balancer defined below
resource "aws_security_group" "alb" {
  name = var.alb_security_group_name

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow outbound for health check requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "Test_ASG" { # References to launch config defined above
  launch_configuration = aws_launch_configuration.Test_ASG.id
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "Kyle-Terra-ASG-Test"
    propagate_at_launch = true
  }
}

/*
Create a load balancer so that user/s will only hit a single IP, since now we're deploying multiple servers
Add listeners to specify howto route requests
*/
resource "aws_lb" "Test-LB" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.Test-LB.arn
  port              = 80
  protocol          = "HTTP"

  # At least 1 default action required...
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  name     = var.alb_name
  port     = var.server_port # Forward to custom defined port 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id # Will use the base one provided for me by AWS Free Tier

  # Add a health check block for the load balancer - if an instance is unhealthy, traffic will stop being routed to it
  health_check {
    path                = "/" # Check sent to the '/' URL of each instance
    protocol            = "HTTP"
    matcher             = "200" # Status OK
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
