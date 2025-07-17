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

-- Create the S3 table with continuous ingest
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
    check_for_updates_on_startup = 1,
    list_object_keys_size = 1000,
    list_object_refresh_time_sec = 60;

-- Create a materialized view to continuously ingest data
CREATE MATERIALIZED VIEW IF NOT EXISTS transactions.s3_to_mergetree TO transactions.daily_transactions AS
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