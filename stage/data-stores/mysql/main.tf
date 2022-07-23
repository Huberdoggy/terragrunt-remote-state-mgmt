provider "aws" {
  region  = "${var.aws_region}"
  profile = "development"
}

resource "aws_db_instance" "Test-DB" {
  engine = "mysql"
  allocated_storage = "10" // In Gigs
  instance_class = "db.t2.micro"
  username = "admin"
  password = "${var.db_password}"
}