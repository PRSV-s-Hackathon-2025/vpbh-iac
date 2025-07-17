#!/bin/bash
set -e

# First set up the continuous mapping
kubectl exec -it $(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}") -- clickhouse-client --multiquery --query="$(cat scripts/setup-continuous-mapping.sql)"

# Then apply the CronJob manifest
kubectl apply -f manifests/clickhouse/refresh-job.yaml

echo "Continuous data mapping from S3 to ClickHouse has been set up successfully"
echo "The CronJob will refresh the S3 table every minute to check for new data"