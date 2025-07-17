#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Get ClickHouse service details
echo "ClickHouse Service Details:"
kubectl get svc clickhouse-service -o wide

# Get ClickHouse ingress details
echo -e "\nClickHouse Ingress Details:"
kubectl get ingress clickhouse-ingress -o wide

# Get ClickHouse pod status
echo -e "\nClickHouse Pod Status:"
kubectl get pods -l app=clickhouse

# Port forward to test ClickHouse
echo -e "\nTesting ClickHouse connection..."
kubectl port-forward svc/clickhouse-service 8123:8123 &
PF_PID=$!

# Wait for port forward to establish
sleep 3

# Test HTTP interface
echo -e "\nTesting ClickHouse HTTP interface:"
curl -s "http://localhost:8123/" || echo "Connection failed"

# Test with simple query
echo -e "\nTesting ClickHouse query:"
curl -s "http://localhost:8123/?query=SELECT%20version()" || echo "Query failed"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "\nClickHouse test completed!"