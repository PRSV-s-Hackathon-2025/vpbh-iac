#!/bin/bash
set -e

echo "Starting comprehensive data loading fix..."

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

echo "Using ClickHouse pod: ${CLICKHOUSE_POD}"

# Create SQL for fixing data loading issues
cat > /tmp/fix-data-load.sql << 'EOF'
-- Drop existing tables
DROP TABLE IF EXISTS transactions.s3_transactions;
DROP TABLE IF EXISTS transactions.daily_transactions;

-- Recreate database
CREATE DATABASE IF NOT EXISTS transactions;

-- Create the main table with correct structure
CREATE TABLE transactions.daily_transactions
(
    transaction_id String,
    account_id String,
    transaction_type String,
    amount Float64,
    currency String,
    merchant_name String,
    category String,
    status String,
    balance_after Float64,
    location String,
    transaction_time String,
    transaction_date Date MATERIALIZED toDate(parseDateTimeBestEffort(transaction_time))
)
ENGINE = MergeTree()
PARTITION BY transaction_date
ORDER BY (transaction_date, account_id, transaction_time)
SETTINGS index_granularity = 8192;

-- Try multiple S3 paths to ensure we find the data
-- First attempt with path format 1
SELECT 'Attempting S3 path format 1...';
INSERT INTO transactions.daily_transactions
SELECT
    transaction_id,
    account_id,
    transaction_type,
    toFloat64(amount),
    currency,
    merchant_name,
    category,
    status,
    toFloat64(balance_after),
    location,
    transaction_time
FROM s3('s3://prsv-vpb-hackathon-transaction-processed/transaction_date=*/run-*-snappy.parquet', 'Parquet');

-- Check if data was loaded
SELECT 'Count after first attempt:';
SELECT COUNT(*) FROM transactions.daily_transactions;

-- If first attempt didn't load enough data, try second path format
SELECT 'Attempting S3 path format 2...';
INSERT INTO transactions.daily_transactions
SELECT
    transaction_id,
    account_id,
    transaction_type,
    toFloat64(amount),
    currency,
    merchant_name,
    category,
    status,
    toFloat64(balance_after),
    location,
    transaction_time
FROM s3('s3://prsv-vpb-hackathon-transaction-data-processed/transaction_date=*/part-*.snappy.parquet', 'Parquet')
WHERE (transaction_id, account_id) NOT IN (
    SELECT transaction_id, account_id FROM transactions.daily_transactions
);

-- Check if data was loaded
SELECT 'Count after second attempt:';
SELECT COUNT(*) FROM transactions.daily_transactions;

-- If second attempt didn't load enough data, try third path format with https
SELECT 'Attempting S3 path format 3...';
INSERT INTO transactions.daily_transactions
SELECT
    transaction_id,
    account_id,
    transaction_type,
    toFloat64(amount),
    currency,
    merchant_name,
    category,
    status,
    toFloat64(balance_after),
    location,
    transaction_time
FROM s3('https://prsv-vpb-hackathon-transaction-data-processed.s3.ap-southeast-1.amazonaws.com/transaction_date=*/part-*.snappy.parquet', 'Parquet')
WHERE (transaction_id, account_id) NOT IN (
    SELECT transaction_id, account_id FROM transactions.daily_transactions
);

-- Final data check
SELECT 'Final data count:';
SELECT COUNT(*) FROM transactions.daily_transactions;

-- Check data distribution by date
SELECT 'Data distribution by date:';
SELECT transaction_date, COUNT(*) FROM transactions.daily_transactions GROUP BY transaction_date ORDER BY transaction_date;
EOF

# Execute the SQL script
echo "Executing comprehensive data loading fix..."
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --multiquery < /tmp/fix-data-load.sql

echo "Data loading fix completed. Run ./scripts/check-data-ingestion.sh to verify."