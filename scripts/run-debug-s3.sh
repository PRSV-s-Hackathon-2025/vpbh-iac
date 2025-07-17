#!/bin/bash
set -e

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

# Execute the debug SQL
echo "Debugging S3 ingestion..."
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --multiquery --query="$(cat scripts/debug-s3-ingestion.sql)"