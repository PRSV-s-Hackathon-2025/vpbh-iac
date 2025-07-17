-- Create the transactions database if it doesn't exist
CREATE DATABASE IF NOT EXISTS transactions;

-- Create the target table if it doesn't exist
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

-- Handle detached table
ATTACH TABLE IF EXISTS transactions.s3_transactions;
DROP TABLE IF EXISTS transactions.s3_transactions;

-- Create the S3 table with the working URL format
CREATE TABLE transactions.s3_transactions (
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
) ENGINE = S3('s3://prsv-vpb-hackathon-transaction-data-processed/transaction_date=*/part-*.snappy.parquet', 
  'Parquet');