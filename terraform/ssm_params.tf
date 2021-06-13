resource "aws_ssm_parameter" "github_secret" {
  name = "/branch_protector/github_secret"
  description = "GitHub username, personal access token, and WebHook secret in JSON format"
  type = "SecureString"
  value = jsonencode(var.github_secret)
}
