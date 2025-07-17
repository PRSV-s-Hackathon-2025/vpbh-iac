#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Check API pod status
echo "API Pod Status:"
kubectl get pods -l app=api-service

# Check API service
echo -e "\nAPI Service:"
kubectl get svc api-service

# Check API ingress
echo -e "\nAPI Ingress:"
kubectl get ingress api-ingress

# Check pod logs
echo -e "\nAPI Pod Logs:"
kubectl logs -l app=api-service --tail=20

# Test service directly
echo -e "\nTesting service directly via port-forward..."
kubectl port-forward svc/api-service 8080:80 &
PF_PID=$!
sleep 3

curl -s "http://localhost:8080/health" || echo "Direct service test failed"

kill $PF_PID 2>/dev/null

echo -e "\nDebug completed!"