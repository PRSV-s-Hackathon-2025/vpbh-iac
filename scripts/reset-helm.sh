#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Remove existing AWS Load Balancer Controller
helm uninstall aws-load-balancer-controller -n kube-system --ignore-not-found

# Clean up any remaining resources
kubectl delete deployment aws-load-balancer-controller -n kube-system --ignore-not-found
kubectl delete serviceaccount aws-load-balancer-controller -n kube-system --ignore-not-found

echo "Reset completed!"