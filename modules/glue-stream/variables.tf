variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers"
  type        = string
}

variable "kafka_security_group_id" {
  description = "Kafka security group ID"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for historical data"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for historical data"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}