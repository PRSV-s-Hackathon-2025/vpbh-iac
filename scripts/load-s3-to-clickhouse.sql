-- Create database
CREATE DATABASE IF NOT EXISTS transactions;

-- Create table for transaction data
CREATE TABLE IF NOT EXISTS transactions.daily_transactions
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
SETTINGS index_granularity = 8192;

-- Create S3 table function to read from S3 bucket
INSERT INTO transactions.daily_transactions
SELECT *
FROM s3(
    'https://prsv-vpb-hackathon-transaction-processed.s3.us-east-1.amazonaws.com/transaction_date=*/run-*.parquet',
    'Parquet'
);