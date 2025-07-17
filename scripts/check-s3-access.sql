-- Drop and recreate the S3 table with a different path pattern
DROP TABLE IF EXISTS transactions.s3_test;

-- Create a test S3 table with a more specific path
CREATE TABLE transactions.s3_test (
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
) ENGINE = S3('https://prsv-vpb-hackathon-transaction-data-processed.s3.ap-southeast-1.amazonaws.com/*', 
  'Parquet');

-- Check if we can access any data
SELECT COUNT(*) FROM transactions.s3_test;

-- Try to list some sample data
SELECT * FROM transactions.s3_test LIMIT 10;

-- Check S3 connection settings
SELECT *
FROM system.settings
WHERE name LIKE '%s3%';