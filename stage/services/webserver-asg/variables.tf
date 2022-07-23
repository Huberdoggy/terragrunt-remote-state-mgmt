variable "server_port" {
  description = "The port the server will listen on for HTTP reqs"
  default     = 8080
}

variable "aws_region" {
  description = "Default to my VPC's US East 1"
  default     = "us-east-1"
}

variable "elb_name" {
  description = "The name of the ELB"
  default     = "Kyle-ELB"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  default     = "Kyle-Instance-SecGroup"
}

variable "elb_security_group_name" {
  description = "The name of the security group for the ALB"
  default     = "Kyle-Elb-SecGroup"
}
