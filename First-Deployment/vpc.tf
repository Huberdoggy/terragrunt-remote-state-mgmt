data "aws_vpc" "default" { # To define target VPC for the Auto Scaling Group in main
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
