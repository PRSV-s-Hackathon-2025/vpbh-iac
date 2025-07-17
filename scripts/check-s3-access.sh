#!/bin/bash
set -e

# Get the ClickHouse pod name
CLICKHOUSE_POD=$(kubectl get pods -l app=clickhouse -o jsonpath="{.items[0].metadata.name}")

# Execute the S3 access test SQL
echo "Testing S3 access..."
kubectl exec -it ${CLICKHOUSE_POD} -- clickhouse-client --multiquery --query="$(cat scripts/check-s3-access.sql)"