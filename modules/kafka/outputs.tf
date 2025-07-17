output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers"
  value       = join(",", [for instance in aws_instance.kafka : "${instance.private_ip}:9092"])
}

output "kafka_security_group_id" {
  description = "Kafka security group ID"
  value       = aws_security_group.kafka.id
}

output "kafka_instance_ids" {
  description = "Kafka instance IDs"
  value       = aws_instance.kafka[*].id
}