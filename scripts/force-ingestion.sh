#!/bin/bash
set -e

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

# Execute the force ingestion SQL
echo "Forcing data ingestion from S3..."
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --multiquery --query="$(cat scripts/force-data-ingestion.sql)"

echo "Data ingestion complete. Run ./scripts/check-data-ingestion.sh to verify."