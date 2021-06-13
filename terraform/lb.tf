# TODO: Enable TLS

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.branch_protector.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.branch_protector.arn
  }
}

resource "aws_lb_target_group" "branch_protector" {
  name     = "tf-example-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb" "branch_protector" {
  name               = "branch-protector-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.branch_protector.id]
  subnets            = var.subnets
}
