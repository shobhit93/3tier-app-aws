locals {
  public_key_filename  = "${var.path}/${var.key_name}.pub"
  private_key_filename = "${var.path}/${var.key_name}.pem"
}

resource "tls_private_key" "algorithm" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.algorithm.public_key_openssh
}
resource "local_file" "public_key_openssh" {
  count    = var.path != "" ? 1 : 0
  content  = tls_private_key.algorithm.public_key_openssh
  filename = local.public_key_filename
}

resource "local_file" "private_key_pem" {
  count    = var.path != "" ? 1 : 0
  content  = tls_private_key.algorithm.private_key_pem
  filename = local.private_key_filename
}

resource "null_resource" "chmod" {
  count      = var.path != "" ? 1 : 0
  depends_on = [local_file.private_key_pem]

  triggers = {
    key = tls_private_key.algorithm.private_key_pem
  }
}
