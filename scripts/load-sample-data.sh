#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get ClickHouse ALB endpoint
CH_URL=$(kubectl get ingress clickhouse-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "ClickHouse URL: http://$CH_URL:8123"

# Insert sample data for testing
echo "Inserting sample transaction data..."
curl -s -X POST "http://$CH_URL:8123/" --data-raw "INSERT INTO transactions.daily_transactions VALUES 
('txn_001', 'user_001', 100.50, 'USD', 'purchase', 'merchant_001', 'Amazon', 'shopping', '2025-05-20 10:30:00', 'completed', 'credit_card', 'US', 'New York', '2025-05-20'),
('txn_002', 'user_002', 75.25, 'USD', 'purchase', 'merchant_002', 'Starbucks', 'food', '2025-05-20 14:15:00', 'completed', 'debit_card', 'US', 'Seattle', '2025-05-20'),
('txn_003', 'user_003', 250.00, 'USD', 'purchase', 'merchant_003', 'Best Buy', 'electronics', '2025-05-21 09:45:00', 'completed', 'credit_card', 'US', 'Chicago', '2025-05-21')"

# Verify sample data
echo -e "\nVerifying sample data..."
curl -s "http://$CH_URL:8123/?query=SELECT%20COUNT(*)%20as%20total_records%20FROM%20transactions.daily_transactions"

echo -e "\nSample records:"
curl -s "http://$CH_URL:8123/?query=SELECT%20*%20FROM%20transactions.daily_transactions%20LIMIT%203%20FORMAT%20JSONEachRow"

echo -e "\nSample data loading completed!"