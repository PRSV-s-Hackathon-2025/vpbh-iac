#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Port forward to ClickHouse pod directly
echo "Setting up port forward to ClickHouse..."
kubectl port-forward svc/clickhouse-service 8123:8123 &
PF_PID=$!
sleep 3

# Drop existing table if exists
echo -e "\nDropping existing table..."
curl -s -X POST "http://localhost:8123/" --data-raw "DROP TABLE IF EXISTS transactions.daily_transactions"

# Recreate database
echo -e "\nRecreating database..."
curl -s -X POST "http://localhost:8123/" --data-raw "CREATE DATABASE IF NOT EXISTS transactions"

# Create table with correct structure
echo -e "\nCreating table with correct structure..."
curl -s -X POST "http://localhost:8123/" --data-raw "CREATE TABLE transactions.daily_transactions
(
    transaction_id String,
    account_id String,
    transaction_type String,
    amount Int64,
    currency String,
    merchant_name String,
    category String,
    status String,
    balance_after Int64,
    location String,
    transaction_time String,
    transaction_date Date MATERIALIZED toDate(parseDateTimeBestEffort(transaction_time))
)
ENGINE = MergeTree()
PARTITION BY transaction_date
ORDER BY (transaction_date, account_id, transaction_time)
SETTINGS index_granularity = 8192"

# Load data from S3
echo -e "\nLoading data from S3..."
curl -s -X POST "http://localhost:8123/" --data-raw "INSERT INTO transactions.daily_transactions (transaction_id, account_id, transaction_type, amount, currency, merchant_name, category, status, balance_after, location, transaction_time) SELECT transaction_id, account_id, transaction_type, amount, currency, merchant_name, category, status, balance_after, location, transaction_time FROM s3('s3://prsv-vpb-hackathon-transaction-processed/transaction_date=*/run-*-snappy.parquet', 'Parquet')"

# Verify data
echo -e "\nVerifying data load..."
curl -s "http://localhost:8123/?query=SELECT%20COUNT(*)%20as%20total_records%20FROM%20transactions.daily_transactions"

echo -e "\nSample loaded data:"
curl -s "http://localhost:8123/?query=SELECT%20*%20FROM%20transactions.daily_transactions%20LIMIT%203%20FORMAT%20JSONEachRow"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nData loading completed successfully!"