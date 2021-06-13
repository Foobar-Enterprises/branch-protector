resource "aws_key_pair" "personal_ssh" {
  key_name   = "personal_ssh_key"
  public_key = var.ssh_key
}
