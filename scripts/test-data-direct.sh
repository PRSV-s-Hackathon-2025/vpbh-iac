#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Port forward to ClickHouse pod directly
echo "Setting up port forward to ClickHouse..."
kubectl port-forward svc/clickhouse-service 8123:8123 &
PF_PID=$!
sleep 3

# Test database exists
echo -e "\nChecking if database exists:"
curl -s "http://localhost:8123/?query=SHOW%20DATABASES"

# Test table exists
echo -e "\nChecking if table exists:"
curl -s "http://localhost:8123/?query=SHOW%20TABLES%20FROM%20transactions"

# Test record count
echo -e "\nTotal record count:"
curl -s "http://localhost:8123/?query=SELECT%20COUNT(*)%20FROM%20transactions.daily_transactions"

# Test sample data
echo -e "\nSample records:"
curl -s "http://localhost:8123/?query=SELECT%20*%20FROM%20transactions.daily_transactions%20LIMIT%203%20FORMAT%20JSONEachRow"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nDirect test completed!"