#!/bin/bash
set -e

# Apply the Deployment manifest
kubectl apply -f manifests/clickhouse/refresh-deployment.yaml

echo "S3 data refresh deployment created successfully"
echo "The process will refresh S3 data every 5 seconds"