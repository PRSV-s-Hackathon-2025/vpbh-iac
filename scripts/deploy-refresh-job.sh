#!/bin/bash
set -e

# Apply the CronJob manifest
kubectl apply -f manifests/clickhouse/refresh-job.yaml

echo "S3 data refresh job deployed successfully"
echo "The job will run every 1 minute to check for new data in S3"