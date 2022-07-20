# Replace single public IP with output that shows DNS name of the load balancer
output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.Test-LB.dns_name
}
