variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "vpc_id" {
  type    = string
  default = "vpc-028ff079"
}

variable "vpc_cidr" {
  description = "Please entere cidr block"
  type        = string
  default     = "192.168.50.0/24"
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
