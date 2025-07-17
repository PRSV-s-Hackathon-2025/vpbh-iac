#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get ClickHouse ALB endpoint
echo "Getting ClickHouse ALB endpoint..."
CH_URL=$(kubectl get ingress clickhouse-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$CH_URL" ]; then
    echo "ClickHouse ALB endpoint not ready yet. Please wait and try again."
    exit 1
fi

echo "ClickHouse URL: http://$CH_URL:8123"

# Execute SQL commands one by one
echo "Creating database..."
curl -s -X POST "http://$CH_URL:8123/" --data-raw "CREATE DATABASE IF NOT EXISTS transactions"

echo -e "\nCreating table..."
curl -s -X POST "http://$CH_URL:8123/" --data-raw "CREATE TABLE IF NOT EXISTS transactions.daily_transactions
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

echo -e "\nLoading data from S3..."
curl -s -X POST "http://$CH_URL:8123/" --data-raw "INSERT INTO transactions.daily_transactions SELECT * FROM s3('s3://prsv-vpb-hackathon-transaction-processed/transaction_date=*/run-*.parquet', 'Parquet')"

# Verify data loaded
echo -e "\nVerifying data load..."
curl -s "http://$CH_URL:8123/?query=SELECT%20COUNT(*)%20FROM%20transactions.daily_transactions"

echo -e "\nChecking partition info..."
curl -s "http://$CH_URL:8123/?query=SELECT%20_partition_id,%20COUNT(*)%20FROM%20transactions.daily_transactions%20GROUP%20BY%20_partition_id%20ORDER%20BY%20_partition_id"

echo -e "\nData loading completed!"