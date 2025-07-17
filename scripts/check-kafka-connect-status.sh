#!/bin/bash

# Set variables
CONNECTOR_NAME="vpbh-bigdata-cluster-kinesis-sink"
REGION="ap-southeast-1"

# Get connector ARN
echo "Getting connector ARN..."
CONNECTOR_ARN=$(aws kafkaconnect list-connectors --region $REGION --query "connectors[?connectorName=='$CONNECTOR_NAME'].connectorArn" --output text)

if [ -z "$CONNECTOR_ARN" ]; then
  echo "Connector not found"
  exit 1
fi

echo "Connector ARN: $CONNECTOR_ARN"

# Get connector status
echo "Getting connector status..."
aws kafkaconnect describe-connector --connector-arn $CONNECTOR_ARN --region $REGION

# Check connector logs
echo "Checking connector logs..."
LOG_GROUP="/aws/kafka-connect/vpbh-bigdata-cluster-kinesis-sink"
LOG_STREAM=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP" --region $REGION --query 'logStreams[0].logStreamName' --output text)

if [ -z "$LOG_STREAM" ]; then
  echo "No log streams found for connector"
  exit 1
fi

echo "Fetching recent logs..."
aws logs get-log-events --log-group-name "$LOG_GROUP" --log-stream-name "$LOG_STREAM" --region $REGION --limit 20