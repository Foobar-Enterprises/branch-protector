output "lb_dns" {
  description = "DNS of the Application Load Balancer"
  value = aws_lb.branch_protector.dns_name
}

output "app_url" {
  description = "DNS of the Application Load Balancer"
  value = "http://${aws_lb.branch_protector.dns_name}:8080"
}

#data "aws_instances" "branch_protector_asg" {
#  instance_tags = {
#    Name = "branch_protector"
#  }
#}
#
#output "ec2-public-ips" {
#  value = data.aws_instances.branch_protector_asg.public_ips
#}
