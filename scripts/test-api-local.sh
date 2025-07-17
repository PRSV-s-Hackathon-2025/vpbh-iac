#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Port forward to API service
echo "Setting up port forward to API service..."
kubectl port-forward svc/api-service 8080:80 &
PF_PID=$!

# Wait for port forward to establish
sleep 3

# Test health endpoint
echo -e "\nTesting health endpoint..."
curl -s "http://localhost:8080/health" | jq . || echo "Health check failed"

# Test query endpoint
echo -e "\nTesting query endpoint..."
curl -s -X POST "http://localhost:8080/query" \
  -H "Content-Type: application/json" \
  -d '{"query": "SELECT 1 as test"}' | jq . || echo "Query test failed"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nLocal API test completed!"