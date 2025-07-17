#!/bin/bash
set -e

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

# Execute query to check data count
echo "Checking current data count in ClickHouse..."
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --query="SELECT COUNT(*) AS total_records FROM transactions.daily_transactions;"

# Check data by date
echo -e "\nData distribution by date:"
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --query="SELECT transaction_date, COUNT(*) AS records FROM transactions.daily_transactions GROUP BY transaction_date ORDER BY transaction_date;"

# Check most recent records
echo -e "\nMost recent 5 records:"
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --query="SELECT transaction_id, account_id, transaction_type, amount, merchant_name, category, transaction_date FROM transactions.daily_transactions ORDER BY transaction_date DESC LIMIT 5 FORMAT PrettyCompact;"