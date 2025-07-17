-- Create the transactions database if it doesn't exist
CREATE DATABASE IF NOT EXISTS transactions;

-- Create the daily_transactions table if it doesn't exist
CREATE TABLE IF NOT EXISTS transactions.daily_transactions (
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
    transaction_date Date
) ENGINE = MergeTree()
ORDER BY (transaction_date, account_id);

-- Create a temporary S3 table to read from
CREATE TABLE IF NOT EXISTS transactions.s3_transactions (
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
    transaction_date Date
) ENGINE = S3('https://prsv-vpb-hackathon-transaction-data-processed.s3.ap-southeast-1.amazonaws.com/transaction_date=*/part-*.snappy.parquet', 'Parquet', 'transaction_date Date');

-- Insert data from S3 into the main table
INSERT INTO transactions.daily_transactions
SELECT
    transaction_id,
    account_id,
    transaction_type,
    amount,
    currency,
    merchant_name,
    category,
    status,
    balance_after,
    location,
    transaction_time,
    transaction_date
FROM transactions.s3_transactions;

-- Show count to verify data was loaded
SELECT COUNT(*) FROM transactions.daily_transactions;