#!/bin/bash

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region ap-southeast-1 --name vpbh-bigdata-cluster

# Create AWS credentials secret for ClickHouse
echo "Creating AWS credentials secret..."
kubectl create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=*** \
  --from-literal=AWS_SECRET_ACCESS_KEY=*** \
  --from-literal=AWS_DEFAULT_REGION=ap-southeast-1 \
  --dry-run=client -o yaml | kubectl apply -f -

# Update ClickHouse deployment to use AWS credentials
echo "Updating ClickHouse deployment with AWS credentials..."
kubectl patch deployment clickhouse -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "clickhouse",
          "env": [
            {"name": "AWS_ACCESS_KEY_ID", "valueFrom": {"secretKeyRef": {"name": "aws-credentials", "key": "AWS_ACCESS_KEY_ID"}}},
            {"name": "AWS_SECRET_ACCESS_KEY", "valueFrom": {"secretKeyRef": {"name": "aws-credentials", "key": "AWS_SECRET_ACCESS_KEY"}}},
            {"name": "AWS_DEFAULT_REGION", "valueFrom": {"secretKeyRef": {"name": "aws-credentials", "key": "AWS_DEFAULT_REGION"}}}
          ]
        }]
      }
    }
  }
}'

# Wait for deployment to restart
kubectl rollout status deployment/clickhouse

echo "AWS credentials configured for ClickHouse!"