-- Create a new S3 table with a different URL format
DROP TABLE IF EXISTS transactions.s3_direct;

CREATE TABLE transactions.s3_direct (
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

-- Try to count records
SELECT COUNT(*) FROM transactions.s3_direct;

-- Try to load data directly
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
FROM transactions.s3_direct
WHERE (transaction_id, account_id) NOT IN (
  SELECT transaction_id, account_id FROM transactions.daily_transactions
);

-- Show count to verify data was loaded
SELECT COUNT(*) FROM transactions.daily_transactions;