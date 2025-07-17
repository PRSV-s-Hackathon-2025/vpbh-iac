#!/bin/bash

# Get the MSK Connect connector name
CONNECTOR_NAME=$(aws kafka-connect list-connectors --region ap-southeast-1 --query 'connectors[0].connectorName' --output text)

if [ -z "$CONNECTOR_NAME" ]; then
  echo "No MSK Connect connectors found"
  exit 1
fi

echo "Found connector: $CONNECTOR_NAME"

# Get connector status
echo "Getting connector status..."
aws kafka-connect describe-connector --connector-name $CONNECTOR_NAME --region ap-southeast-1

# Check connector logs
echo "Checking connector logs..."
LOG_GROUP="/aws/kafka-connect/vpbh-bigdata-cluster-kinesis-sink"
LOG_STREAM=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP" --region ap-southeast-1 --query 'logStreams[0].logStreamName' --output text)

if [ -z "$LOG_STREAM" ]; then
  echo "No log streams found for connector"
  exit 1
fi

echo "Fetching recent logs..."
aws logs get-log-events --log-group-name "$LOG_GROUP" --log-stream-name "$LOG_STREAM" --region ap-southeast-1 --limit 20