# Replace single public IP with output that shows DNS name of the load balancer
output "elb_dns_name" {
  value       = "${aws_elb.Test-LB.dns_name}"
}
