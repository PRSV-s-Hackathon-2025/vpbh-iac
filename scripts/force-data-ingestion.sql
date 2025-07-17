-- Recreate the S3 table to force refresh
DETACH TABLE IF EXISTS transactions.s3_transactions;

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
) ENGINE = S3('https://prsv-vpb-hackathon-transaction-data-processed.s3.ap-southeast-1.amazonaws.com/transaction_date=*/part-*.snappy.parquet', 
  'Parquet', 
  'transaction_date Date')
SETTINGS
  s3_check_objects_after_refresh = true,
  s3_list_object_keys_size = 5000;

-- Manually insert data from S3 to daily_transactions
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
FROM transactions.s3_transactions
WHERE (transaction_id, account_id) NOT IN (
  SELECT transaction_id, account_id FROM transactions.daily_transactions
);

-- Show count to verify data was loaded
SELECT COUNT(*) FROM transactions.daily_transactions;