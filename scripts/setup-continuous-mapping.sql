-- Create the transactions database if it doesn't exist
CREATE DATABASE IF NOT EXISTS transactions;

-- Create the target table
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

-- Create a dictionary table to track processed files
CREATE TABLE IF NOT EXISTS transactions.processed_files (
    file_path String,
    processed_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (file_path);

-- Create the S3 table with continuous ingest settings
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
) ENGINE = S3('https://prsv-vpb-hackathon-transaction-data-processed.s3.ap-southeast-1.amazonaws.com/transaction_date=*/part-*.snappy.parquet', 
    'Parquet', 
    'transaction_date Date')
SETTINGS
    s3_check_objects_after_refresh = true,
    s3_list_object_keys_size = 5000,
    s3_retry_attempts = 10,
    s3_max_single_read_retries = 10,
    s3_retry_backoff_max_ms = 10000,
    s3_retry_backoff_base_ms = 100,
    s3_request_timeout_ms = 60000,
    s3_list_objects_timeout_ms = 60000;

-- Create a materialized view to insert new data
CREATE MATERIALIZED VIEW IF NOT EXISTS transactions.s3_to_mergetree TO transactions.daily_transactions
AS SELECT 
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
FROM transactions.s3_transactions
WHERE (transaction_id, account_id) NOT IN (
    SELECT transaction_id, account_id FROM transactions.daily_transactions
);