#!/bin/bash
set -e

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

# Execute the SQL file directly
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --multiquery --query="$(cat scripts/setup-continuous-ingest.sql)"

echo "Continuous ingestion from S3 to ClickHouse has been set up successfully"