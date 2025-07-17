#!/bin/bash
set -e

# Delete old CronJob if it exists
kubectl delete cronjob clickhouse-s3-refresh --ignore-not-found

# Apply the new scaled-down CronJob
kubectl apply -f manifests/clickhouse/working-refresh-job.yaml

echo "Scaled-down S3 ingestion solution deployed successfully"
echo "The job will now run every 5 minutes to reduce message rate"