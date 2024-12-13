# Output the Load Balancer DNS
output "load_balancer_dns" {
  value = aws_lb.main_lb.dns_name
  description = "DNS name of the Elastic Load Balancer"
}

# Output the Auto Scaling group
output "autoscaling_group_id" {
  value = aws_autoscaling_group.asg.id
  description = "The Auto Scaling Group ID"
}
