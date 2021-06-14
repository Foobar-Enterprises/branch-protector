variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-028ff079"
}

variable "ssh_key" {
  description = "Your personal public SSH key"
  type        = string
}

variable "subnets" {
  description = "Subnets to place EC2 instances in"
  type        = list(string)
}

variable "github_secret" {
  description = "GitHub username, personal access token, and WebHook secret in JSON format"
  type        = map(string)
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}
