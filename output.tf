
# ALB DNS is generated dynamically, return URL so that it can be used
output "app_elb_url" {
  description = "backend app server loadbalancer url"
  value = "http://${aws_elb.app_elb.dns_name}/"
}

output "Domain_Url" {
  description = "Domain url for web application"
  value = "http://${aws_route53_record.www.name}/"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.rds.endpoint
}