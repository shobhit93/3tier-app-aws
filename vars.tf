# Put the following two keys into shell or env variables

variable "infra_name" {
  description = "Naming conventions for infra"
  default     = "3tier-infra"
}

variable "aws_region" {
  description = "US WEST"
  default     = "us-west-1"
}

variable "ec2_amis" {
  description = "Ubuntu Server 18.04 LTS (HVM)"
  default     = "ami-0e4035ae3f70c400f" 
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.1.5.0/24", "10.1.7.0/24"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.3.0/24"]
}

variable "vpc_cidr" {
#  type    = list(string)
  default = "10.1.0.0/16"
}

variable "key_name" {
  description = "Unique name for the key, should also be a valid filename. This will prefix the public/private key."
  default = "ec2-key-terraform" # in our case!
}

variable "path" {
  description = "Path to a directory where the public and private key will be stored."
  default     = "C:\\Users\\Shobhit Pandey\\Desktop\\SHOBHIT WORK"
}

variable "aws_creds_path" {
  description = "path of aws creds"
  default     = "C:\\Users\\Shobhit Pandey\\.aws\\credentials"
}

variable "rds_storage" {
  description = "RDS storage space"
  default     = "10"
}

variable "rds_engine" {
  description = "RDS engine type"
  default     = "mysql"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  default     = "db.t2.micro"
}

variable "rds_name" {
  description = "Name of the RDS"
  default     = "mysql_rds"
}

variable "rds_username" {
  description = "Username of the RDS"
  default     = "mysql_terraform"
}

variable "rds_password" {
  description = "Password of the RDS"
  default     = "terraformrds"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  default     = 5432
}

variable "db_subnets_cidr" {
  description = "CIDR blocks of subnets in DB layer"
  default     = ["10.1.2.0/24", "10.1.4.0/24"]
}
