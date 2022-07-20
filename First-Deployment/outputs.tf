output "public_ip" {
	value = "${aws_instance.Test1.public_ip}"
}