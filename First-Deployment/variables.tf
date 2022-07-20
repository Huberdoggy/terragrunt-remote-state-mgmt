variable "server_port" {
  description = "The port the server will listen on for HTTP reqs"
  type        = number
  default     = 8080
}

variable "aws_region" {
  description = "Default to my VPC's US East 1"
  default     = "us-east-1"
}
