-- Check S3 table structure
SHOW CREATE TABLE transactions.s3_transactions;

-- Check if S3 table has data
SELECT COUNT(*) FROM transactions.s3_transactions;

-- Check sample data from S3
SELECT * FROM transactions.s3_transactions LIMIT 5;

-- Check materialized view
SHOW CREATE TABLE transactions.s3_to_mergetree;

-- Check if there are any errors in the system log related to S3
SELECT 
    event_time,
    message
FROM system.text_log
WHERE message LIKE '%S3%' OR message LIKE '%s3%'
ORDER BY event_time DESC
LIMIT 20;