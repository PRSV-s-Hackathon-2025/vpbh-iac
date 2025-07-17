#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Port forward to ClickHouse pod directly
echo "Setting up port forward to ClickHouse..."
kubectl port-forward svc/clickhouse-service 8123:8123 &
PF_PID=$!
sleep 3

# Test 1: Total record count
echo -e "\n1. Total transaction count:"
curl -s "http://localhost:8123/?query=SELECT%20COUNT(*)%20as%20total_transactions%20FROM%20transactions.daily_transactions"

# Test 2: Records by date
echo -e "\n2. Transactions by date:"
curl -s "http://localhost:8123/?query=SELECT%20transaction_date,%20COUNT(*)%20as%20count%20FROM%20transactions.daily_transactions%20GROUP%20BY%20transaction_date%20ORDER%20BY%20transaction_date%20FORMAT%20JSONEachRow"

# Test 3: Transaction amounts summary
echo -e "\n3. Transaction amount summary:"
curl -s "http://localhost:8123/?query=SELECT%20MIN(amount)%20as%20min_amount,%20MAX(amount)%20as%20max_amount,%20AVG(amount)%20as%20avg_amount%20FROM%20transactions.daily_transactions%20FORMAT%20JSONEachRow"

# Test 4: Top categories
echo -e "\n4. Top transaction categories:"
curl -s "http://localhost:8123/?query=SELECT%20category,%20COUNT(*)%20as%20count,%20SUM(amount)%20as%20total_amount%20FROM%20transactions.daily_transactions%20GROUP%20BY%20category%20ORDER%20BY%20count%20DESC%20FORMAT%20JSONEachRow"

# Test 5: Top merchants
echo -e "\n5. Top merchants:"
curl -s "http://localhost:8123/?query=SELECT%20merchant_name,%20COUNT(*)%20as%20transaction_count%20FROM%20transactions.daily_transactions%20GROUP%20BY%20merchant_name%20ORDER%20BY%20transaction_count%20DESC%20LIMIT%2010%20FORMAT%20JSONEachRow"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nData testing completed!"