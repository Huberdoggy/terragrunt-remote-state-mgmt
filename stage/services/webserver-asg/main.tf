provider "aws" {
  region  = "${var.aws_region}"
  profile = "development"
}


# Modified to create an Auto Scaling group instead of a single instance
resource "aws_launch_configuration" "Test_ASG" {
  image_id        = "ami-0070c5311b7677678"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
   
  user_data       = "${data.template_file.user_data.rendered}" // Point to my external Bash script. See further below

  lifecycle {                    # Required meta parameter for ASGs
    create_before_destroy = true # Will wait to rm old EC2 instance until the new one comes up
  }
}

resource "aws_security_group" "instance" {
  name = "${var.instance_security_group_name}"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Sec group for the load balancer defined below
resource "aws_security_group" "elb" {
  name = "${var.elb_security_group_name}"

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
  launch_configuration = "${aws_launch_configuration.Test_ASG.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  load_balancers       = ["${aws_elb.Test-LB.name}"]
  health_check_type    = "ELB"

  min_size         = 2
  max_size         = 10
  desired_capacity = 4 // More predictable

  tag {
    key                 = "Name"
    value               = "Kyle-Terra-ASG-Test"
    propagate_at_launch = true 
  }
}

data "aws_availability_zones" "all" {} // Define data for using any zone available in my region

// So that the web server cluster can access the data
data "terraform_remote_state" "mysql-db" {
  backend = "s3"
  config {
    bucket = "huberdoggy-s3-bucket"
    key = "stage/data-stores/mysql/terraform.tfstate" // Will return read-only state stored in S3 bucket pertaining to the DB path
    region = "${var.aws_region}"
  }
}
// Can now use template_file interpolation to write the output vars into 'index'
// Note, 'template_file' allows us to access the dynamic values when the script is external
data "template_file" "user_data" {
  template = "${file("user-data.sh")}"
  // Has 1 attrib called 'rendered' aka the result of rendering defined 'template', which includes
  // interpolated syntax. Therefore, we need to explicitly re-define var values here to become available and used by the script:
  vars {
    server_port = "${var.server_port}"
    db_address = "${data.terraform_remote_state.mysql-db.address}"
    db_port = "${data.terraform_remote_state.mysql-db.port}"
  }
}
/*
Create a load balancer so that user/s will only hit a single IP, since now we're deploying multiple servers
Add listeners to specify howto route requests
*/
resource "aws_elb" "Test-LB" {
  name               = "${var.elb_name}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}" # Forward to custom defined port 8080
    instance_protocol = "http"
  }
  # Add a health check block for the load balancer - if an instance is unhealthy, traffic will stop being routed to it
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/" # Check sent to the '/' URL of each instance
  }
}
