#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get ClickHouse ALB endpoint
CH_URL=$(kubectl get ingress clickhouse-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "ClickHouse URL: http://$CH_URL:8123"

# Test queries
echo -e "\n1. Total transaction count:"
curl -s "http://$CH_URL:8123/?query=SELECT%20COUNT(*)%20as%20total_transactions%20FROM%20transactions.daily_transactions"

echo -e "\n2. Transactions by date:"
curl -s "http://$CH_URL:8123/?query=SELECT%20transaction_date,%20COUNT(*)%20as%20count%20FROM%20transactions.daily_transactions%20GROUP%20BY%20transaction_date%20ORDER%20BY%20transaction_date"

echo -e "\n3. Top 10 transaction amounts:"
curl -s "http://$CH_URL:8123/?query=SELECT%20amount,%20currency,%20merchant_name%20FROM%20transactions.daily_transactions%20ORDER%20BY%20amount%20DESC%20LIMIT%2010"

echo -e "\n4. Transactions by category:"
curl -s "http://$CH_URL:8123/?query=SELECT%20category,%20COUNT(*)%20as%20count,%20SUM(amount)%20as%20total_amount%20FROM%20transactions.daily_transactions%20GROUP%20BY%20category%20ORDER%20BY%20count%20DESC"

echo -e "\nQuery testing completed!"