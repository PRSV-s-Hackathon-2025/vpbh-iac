#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get API ALB endpoint
echo "Getting API ALB endpoint..."
ALB_URL=$(kubectl get ingress api-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_URL" ]; then
    echo "ALB endpoint not ready yet. Please wait and try again."
    exit 1
fi

echo "API URL: http://$ALB_URL"

# Test health endpoint
echo -e "\nTesting health endpoint..."
curl -s "http://$ALB_URL/health" | jq . || echo "Health check failed"

# Test query endpoint with simple query
echo -e "\nTesting query endpoint..."
curl -s -X POST "http://$ALB_URL/query" \
  -H "Content-Type: application/json" \
  -d '{"query": "SELECT 1 as test"}' | jq . || echo "Query test failed"

# Test ClickHouse version query
echo -e "\nTesting ClickHouse version query..."
curl -s -X POST "http://$ALB_URL/query" \
  -H "Content-Type: application/json" \
  -d '{"query": "SELECT version()"}' | jq . || echo "Version query failed"

echo -e "\nAPI test completed!"