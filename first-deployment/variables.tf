variable "server_port" {
  description = "The port the server will listen on for HTTP reqs"
  type        = number
  default     = 8080
}

variable "aws_region" {
  description = "Default to my VPC's US East 1"
  default     = "us-east-1"
}

variable "alb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "Kyle-ALB"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type        = string
  default     = "Kyle-Instance-SecGroup"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "Kyle-Alb-SecGroup"
}
