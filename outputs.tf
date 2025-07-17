output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}



# Kinesis stream outputs removed as the module no longer exists

output "historical_bucket_name" {
  description = "Historical S3 bucket name"
  value       = module.s3_historical.bucket_name
}

output "processed_bucket_name" {
  description = "Processed data S3 bucket name"
  value       = "prsv-vpb-hackathon-transaction-processed"
}

output "confluent_kafka_bootstrap_servers" {
  description = "Confluent Kafka bootstrap servers"
  value       = "pkc-312o0.ap-southeast-1.aws.confluent.cloud:9092"
}