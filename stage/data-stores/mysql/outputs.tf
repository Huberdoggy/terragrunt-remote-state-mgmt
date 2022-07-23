// For webserver cluster accessibility

output "address" {
  value = "${aws_db_instance.Test-DB.address}"
}

output "port" {
  value = "${aws_db_instance.Test-DB.port}"
}