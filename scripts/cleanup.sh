#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Delete manifests
echo "Cleaning up 2048 game application..."
kubectl delete -f ./manifests/2048-game/

echo "Cleanup completed!"