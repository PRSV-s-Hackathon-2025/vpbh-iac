output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.api.certificate_arn
}

output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}