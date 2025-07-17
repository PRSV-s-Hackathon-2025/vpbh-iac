#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Check ClickHouse pod status
echo "ClickHouse Pod Status:"
kubectl get pods -l app=clickhouse

# Check ClickHouse logs
echo -e "\nClickHouse Pod Logs:"
kubectl logs -l app=clickhouse --tail=20

# Check ClickHouse service
echo -e "\nClickHouse Service:"
kubectl get svc clickhouse-service

# Test direct pod connection
echo -e "\nTesting direct pod connection..."
POD_NAME=$(kubectl get pods -l app=clickhouse -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$POD_NAME" ]; then
    kubectl port-forward $POD_NAME 8123:8123 &
    PF_PID=$!
    sleep 3
    curl -s "http://localhost:8123/" || echo "Direct pod connection failed"
    kill $PF_PID 2>/dev/null
fi

echo -e "\nDebug completed!"