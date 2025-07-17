#!/bin/bash

echo "Deploying streaming data pipeline..."

# Initialize and deploy new modules
terraform init
terraform apply -target=module.kinesis_stream -target=module.kinesis_kafka_bridge -auto-approve

echo "✅ Kinesis stream and Kafka bridge deployed"

# Start Glue streaming job
GLUE_JOB_NAME=$(terraform output -raw kinesis_stream_name | sed 's/transactions/kinesis-streaming/')
aws glue start-job-run --job-name "$GLUE_JOB_NAME-streaming"

echo "✅ Glue streaming job started"
echo "Pipeline: Kafka → Kinesis → Glue → S3 (prsv-vpb-hackathon-transaction-processed)"