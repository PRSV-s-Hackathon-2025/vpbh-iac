#!/bin/bash

# Set variables
CONNECTOR_NAME="vpbh-bigdata-cluster-kinesis-sink"
REGION="ap-southeast-1"
KINESIS_STREAM="vpbh-bigdata-cluster-transactions"
BOOTSTRAP_SERVERS="pkc-312o0.ap-southeast-1.aws.confluent.cloud:9092"

# Get connector ARN
echo "Getting connector ARN..."
CONNECTOR_ARN=$(aws kafkaconnect list-connectors --region $REGION --query "connectors[?connectorName=='$CONNECTOR_NAME'].connectorArn" --output text)

if [ -z "$CONNECTOR_ARN" ]; then
  echo "Connector not found"
  exit 1
fi

echo "Connector ARN: $CONNECTOR_ARN"

# Get current version
echo "Getting current version..."
CURRENT_VERSION=$(aws kafkaconnect describe-connector --connector-arn $CONNECTOR_ARN --region $REGION --query 'currentVersion' --output text)

echo "Current version: $CURRENT_VERSION"

# Create a temporary file for the updated connector configuration
cat > connector-config.json << 'EOF'
{
  "connectorArn": "'$CONNECTOR_ARN'",
  "currentVersion": "'$CURRENT_VERSION'",
  "connectorConfiguration": {
    "connector.class": "com.amazon.kinesis.kafka.connect.KinesisSinkConnector",
    "tasks.max": "1",
    "topics": "transactions",
    "aws.region": "ap-southeast-1",
    "kinesis.stream": "vpbh-bigdata-cluster-transactions",
    "batch.size": "100",
    "batch.max.size.bytes": "1048576",
    "transforms": "LocationNormalizer",
    "transforms.LocationNormalizer.type": "org.apache.kafka.connect.transforms.InsertField$Value",
    "transforms.LocationNormalizer.static.field": "location_normalized",
    "transforms.LocationNormalizer.static.value": "normalized_location"
  },
  "capacity": {
    "autoScaling": {
      "mcuCount": 1,
      "minWorkerCount": 1,
      "maxWorkerCount": 2,
      "scaleInPolicy": {
        "cpuUtilizationPercentage": 20
      },
      "scaleOutPolicy": {
        "cpuUtilizationPercentage": 80
      }
    }
  }
}
EOF

# Update the connector configuration only
echo "Updating connector configuration..."
aws kafkaconnect update-connector --connector-arn $CONNECTOR_ARN --current-version $CURRENT_VERSION --connector-configuration '{"connector.class":"com.amazon.kinesis.kafka.connect.KinesisSinkConnector","tasks.max":"1","topics":"transactions","aws.region":"ap-southeast-1","kinesis.stream":"vpbh-bigdata-cluster-transactions","batch.size":"100","batch.max.size.bytes":"1048576","transforms":"LocationNormalizer","transforms.LocationNormalizer.type":"org.apache.kafka.connect.transforms.InsertField$Value","transforms.LocationNormalizer.static.field":"location_normalized","transforms.LocationNormalizer.static.value":"normalized_location"}' --region $REGION

# Clean up
rm connector-config.json

echo "Connector update initiated."