#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Deploy manifests
echo "Deploying 2048 game application..."
kubectl apply -f ./manifests/2048-game/

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/game-2048

# Get ingress URL
echo "Getting ingress URL..."
kubectl get ingress game-2048-ingress

echo "Deployment completed!"