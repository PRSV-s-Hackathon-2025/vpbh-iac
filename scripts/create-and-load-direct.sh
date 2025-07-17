#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Port forward to ClickHouse pod directly
echo "Setting up port forward to ClickHouse..."
kubectl port-forward svc/clickhouse-service 8123:8123 &
PF_PID=$!
sleep 3

# Create database
echo -e "\nCreating database..."
curl -s -X POST "http://localhost:8123/" --data-raw "CREATE DATABASE IF NOT EXISTS transactions"

# Create table
echo -e "\nCreating table..."
curl -s -X POST "http://localhost:8123/" --data-raw "CREATE TABLE IF NOT EXISTS transactions.daily_transactions
(
    transaction_id String,
    user_id String,
    amount Decimal64(2),
    currency String,
    transaction_type String,
    merchant_id String,
    merchant_name String,
    category String,
    timestamp DateTime64(3),
    status String,
    payment_method String,
    country String,
    city String,
    transaction_date Date
)
ENGINE = MergeTree()
PARTITION BY transaction_date
ORDER BY (transaction_date, user_id, timestamp)
SETTINGS index_granularity = 8192"

# Load data from S3
echo -e "\nLoading data from S3..."
curl -s -X POST "http://localhost:8123/" --data-raw "INSERT INTO transactions.daily_transactions SELECT * FROM s3('s3://prsv-vpb-hackathon-transaction-processed/transaction_date=*/run-*.parquet', 'Parquet')"

# Verify data
echo -e "\nVerifying data load..."
curl -s "http://localhost:8123/?query=SELECT%20COUNT(*)%20FROM%20transactions.daily_transactions"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nDirect creation and loading completed!"