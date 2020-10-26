provider "aws" {
  shared_credentials_file = "$file(var.aws_creds_path)"
  profile                 = "default"
  region = var.aws_region
}

