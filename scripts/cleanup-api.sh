#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Delete API manifests
echo "Cleaning up API service..."
kubectl delete -f ./manifests/api/

echo "API cleanup completed!"