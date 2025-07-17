#!/bin/bash
set -e

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

# Set up the initial tables
echo "Setting up tables with working configuration..."
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --multiquery --query="$(cat scripts/setup-working-ingestion.sql)" || true

# Delete old CronJob if it exists
kubectl delete cronjob clickhouse-s3-refresh --ignore-not-found

# Apply the new CronJob
kubectl apply -f manifests/clickhouse/working-refresh-job.yaml

echo "Working S3 ingestion solution deployed successfully"
echo "The job will run every minute to check for new data in S3"