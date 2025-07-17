variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "zone_name" {
  description = "Route53 hosted zone name"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB zone ID"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}