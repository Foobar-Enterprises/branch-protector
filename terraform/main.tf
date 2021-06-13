data "http" "icanhazip" {
 url = "https://icanhazip.com"
}

resource "aws_security_group" "branch_protector" {
  name = "branch_protector"
  description = "Security group for Branch Protector"
  vpc_id = var.vpc_id

  // Allow SSH to my personal IP address
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${chomp(data.http.icanhazip.body)}/32"]
  }

  // Allow 8080 to my personal IP address and GitHub
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["192.30.252.0/22", "140.82.112.0/20", "${chomp(data.http.icanhazip.body)}/32"]
    self = true  // Required for the health checks
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
