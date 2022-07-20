provider "aws" {
  region  = var.aws_region
  profile = "development"
}

resource "aws_instance" "Test1" {
  ami                    = "ami-40d28157"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data              = <<-EOF
			#!/bin/bash
			echo -e "Kyle, the wizard, execs shell command into index\nAnd spins up web server on port 8080" > index.html
			nohup busybox httpd -fp "${var.server_port}" &
			EOF
  tags = {
    Name = "Kyle-AutomatedDeployment"
  }
}

resource "aws_security_group" "instance" {
  name = "Kyle-AutomatedDeployment-Instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
