resource "aws_placement_group" "branch_protector" {
  name     = "branch_protector"
  strategy = "partition"
}

resource "aws_autoscaling_group" "branch_protector" {
  name                      = "branch_protector"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  placement_group           = aws_placement_group.branch_protector.id
  launch_configuration      = aws_launch_configuration.branch_protector.name
  availability_zones        = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  target_group_arns         = [aws_lb_target_group.branch_protector.arn]
  tag {
    key = "Name"
    value = "branch_protector"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "branch_protector" {
  name          = "branch_protector"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.branch_protector.id
  ]
  key_name     = aws_key_pair.personal_ssh.key_name
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  user_data    = <<EOF
#!/bin/bash
sudo yum update -y &&
sudo yum install -y docker jq &&
sudo usermod -a -G docker ec2-user &&
sudo service docker start &&
sudo docker pull jodawill1989/branch_protector:latest &&
aws ssm get-parameter --name /branch_protector/github_secret --region us-east-1 --with-decryption | jq -r .Parameter.Value > /tmp/github_secret.json
sudo docker run -it --rm -v /tmp/github_secret.json:/run/secrets/github.json -d -p 8080:8080 --name branch_protector jodawill1989/branch_protector:latest
EOF
}
