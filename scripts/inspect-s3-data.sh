#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Port forward to ClickHouse pod directly
echo "Setting up port forward to ClickHouse..."
kubectl port-forward svc/clickhouse-service 8123:8123 &
PF_PID=$!
sleep 3

# Inspect S3 data structure
echo -e "\nInspecting S3 data structure..."
curl -s -X POST "http://localhost:8123/" --data-raw "DESCRIBE s3('s3://prsv-vpb-hackathon-transaction-processed/transaction_date=*/run-*-snappy.parquet', 'Parquet')"

# Show sample data
echo -e "\nSample S3 data:"
curl -s -X POST "http://localhost:8123/" --data-raw "SELECT * FROM s3('s3://prsv-vpb-hackathon-transaction-processed/transaction_date=*/run-*-snappy.parquet', 'Parquet') LIMIT 3 FORMAT JSONEachRow"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nS3 data inspection completed!"