#!/bin/bash
set -e

# Delete the CronJob
kubectl delete cronjob clickhouse-s3-refresh

echo "S3 data refresh CronJob deleted successfully"