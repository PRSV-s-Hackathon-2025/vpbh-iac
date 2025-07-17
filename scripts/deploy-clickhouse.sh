#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Deploy ClickHouse
echo "Deploying ClickHouse..."
kubectl apply -f ./manifests/clickhouse/

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/clickhouse

# Get ClickHouse service and ingress
echo "Getting ClickHouse service..."
kubectl get svc clickhouse-service

echo "Getting ClickHouse ingress..."
kubectl get ingress clickhouse-ingress

echo "ClickHouse deployment completed!"