#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get ALB endpoint
echo "Getting ClickHouse ALB endpoint..."
ALB_URL=$(kubectl get ingress clickhouse-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_URL" ]; then
    echo "ALB endpoint not ready yet. Please wait and try again."
    exit 1
fi

echo "ALB URL: http://$ALB_URL:8123"

# Test ClickHouse connection via ALB
echo -e "\nTesting ClickHouse via ALB..."
curl -s "http://$ALB_URL:8123/" || echo "Connection failed"

# Test ClickHouse version query via ALB
echo -e "\nTesting ClickHouse version query via ALB..."
curl -s "http://$ALB_URL:8123/?query=SELECT%20version()" || echo "Query failed"

# Test simple query
echo -e "\nTesting simple query via ALB..."
curl -s "http://$ALB_URL:8123/?query=SELECT%201" || echo "Query failed"

echo -e "\nClickHouse ALB test completed!"