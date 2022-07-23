variable "db_password" {
  description = "The password for the MySQL database. (Environmentally exported during testing)"
}

variable "aws_region" {
  description = "Default to my VPC's US East 1"
  default     = "us-east-1"
}