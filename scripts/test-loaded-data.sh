#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get ClickHouse ALB endpoint
CH_URL=$(kubectl get ingress clickhouse-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "ClickHouse URL: http://$CH_URL:8123"

# Test 1: Total record count
echo -e "\n1. Total transaction count:"
curl -s "http://$CH_URL:8123/?query=SELECT%20COUNT(*)%20as%20total_transactions%20FROM%20transactions.daily_transactions"

# Test 2: Records by date
echo -e "\n2. Transactions by date:"
curl -s "http://$CH_URL:8123/?query=SELECT%20transaction_date,%20COUNT(*)%20as%20count%20FROM%20transactions.daily_transactions%20GROUP%20BY%20transaction_date%20ORDER%20BY%20transaction_date%20FORMAT%20JSONEachRow"

# Test 3: Sample records
echo -e "\n3. Sample transaction records:"
curl -s "http://$CH_URL:8123/?query=SELECT%20*%20FROM%20transactions.daily_transactions%20LIMIT%205%20FORMAT%20JSONEachRow"

# Test 4: Transaction amounts summary
echo -e "\n4. Transaction amount summary:"
curl -s "http://$CH_URL:8123/?query=SELECT%20MIN(amount)%20as%20min_amount,%20MAX(amount)%20as%20max_amount,%20AVG(amount)%20as%20avg_amount%20FROM%20transactions.daily_transactions%20FORMAT%20JSONEachRow"

# Test 5: Top categories
echo -e "\n5. Top transaction categories:"
curl -s "http://$CH_URL:8123/?query=SELECT%20category,%20COUNT(*)%20as%20count,%20SUM(amount)%20as%20total_amount%20FROM%20transactions.daily_transactions%20GROUP%20BY%20category%20ORDER%20BY%20count%20DESC%20LIMIT%2010%20FORMAT%20JSONEachRow"

# Test 6: Partition information
echo -e "\n6. Partition information:"
curl -s "http://$CH_URL:8123/?query=SELECT%20partition,%20rows,%20bytes_on_disk%20FROM%20system.parts%20WHERE%20table%20=%20%27daily_transactions%27%20AND%20database%20=%20%27transactions%27%20FORMAT%20JSONEachRow"

echo -e "\nData testing completed!"