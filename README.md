# 3tier-app-aws
3 tier application in aws through terraform

This is an implementation of the classic three tier architecture for application hosting.  <br />
Three modules that constructs our architecture:
* [app] --> Backend Application server
* [web] --> web Application server
* [db] --> RDS server

## How to deploy

Setup:
* [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
* Setup your credentials via [AWS Provider](https://www.terraform.io/docs/providers/aws/index.html#access_key)
* Clone this project


## Main terraform module inputs

| Name                  | Description                                           | Type   | Default | Required |
| ------                | -------------                                         | :----: | :-----: | :-----:  |
| infra_name            | Naming conventions for infra                          | string | -       | yes      |
| aws_region            | AWS region where you have to put your infra           | string | -       | yes      |
| ec2_amis              | AMI used for creating ec2 instances                   | string | -       | yes      |
| vpc_cidr              | The cidr range for vpc                                | string | -       | yes      |
| db_subnets_cidr       | The cidr range for db				                    | string | -       | yes      |
| private_subnet_cidr   | The cidr range for private subnet                     | string | -       | yes      |
| public_subnet_cidr    | The cidr range for public subnet                      | string | -       | yes      |
| key_name              | Unique name for the keypair                           | string | -       | yes      |
| path                  | Path to a directory where key will be stored.         | string | -       | yes      |
| aws_creds_path        | path of aws creds                                     | string | -       | yes      |
| rds_storage           | RDS storage space                                     | string | -       | yes      |
| rds_engine            | RDS engine type                                       | string | -       | yes      |
| rds_instance_class    | RDS instance class                                    | string | -       | yes      |
| rds_name              | Name of the RDS                                       | string | -       | yes      |
| rds_username          | Username of the RDS                                   | string | -       | yes      |
| rds_password          | Password of the RDS                                   | string | -       | yes      |
| db_port               | The port on which the DB accepts connections          | string | -       | yes      |

## Outputs

| Name         | Description                         |
| ------       | -------------                       |
| app_elb_url  | backend app server loadbalancer url |
| Domain_Url   | Domain url for web application      |
| rds_endpoint | RDS endpoint                        |

## Command Line Examples
To setup provisioner
```
$ terraform init
```

plan the launch the 3tier-app-aws:
```
$ terraform plan -out=aws.tfplan
```
or with custom variable in tf.vars file
```
$ terraform plan -out=aws.tfplan -var-file=tf.vars
```
apply the launch the 3tier-app-aws:
```
$ terraform apply aws.tfplan
```
To teardown the 3tier-app-aws:
```
$ terraform destroy


