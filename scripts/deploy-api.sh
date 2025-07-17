#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Deploy API service
echo "Deploying API service..."
kubectl apply -f ./manifests/api/

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/api-service

# Get API service and ingress
echo "Getting API service..."
kubectl get svc api-service

echo "Getting API ingress..."
kubectl get ingress api-ingress

echo "API deployment completed!"