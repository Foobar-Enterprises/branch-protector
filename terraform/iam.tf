resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "branch_protector_instance_profile"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [aws_ssm_parameter.github_secret.arn]
  }
}

resource "aws_iam_role_policy" "ssm_access" {
  name  = "branch_protector_ssm_access"
  role  = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.ssm_access.json
}
