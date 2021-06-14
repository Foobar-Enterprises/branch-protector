output "lb_dns" {
  description = "DNS of the Application Load Balancer"
  value = aws_lb.branch_protector.dns_name
}

output "app_url" {
  description = "Webhook URL"
  value = "http://${aws_lb.branch_protector.dns_name}:8080/webhook"
}
