#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Delete ClickHouse manifests
echo "Cleaning up ClickHouse..."
kubectl delete -f ./manifests/clickhouse/

echo "ClickHouse cleanup completed!"