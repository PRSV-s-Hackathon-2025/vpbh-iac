#!/bin/bash

echo "Testing Glue to Kafka connectivity..."

# Get Kafka instance IPs
KAFKA_IPS=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*kafka*" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].PrivateIpAddress' \
  --output text)

if [ -z "$KAFKA_IPS" ]; then
  echo "❌ No running Kafka instances found"
  exit 1
fi

echo "✅ Found Kafka instances at: $KAFKA_IPS"

# Check Glue connection
GLUE_CONNECTION=$(aws glue get-connection --name "*kafka-connection" --query 'Connection.Name' --output text 2>/dev/null)

if [ "$GLUE_CONNECTION" = "None" ]; then
  echo "❌ Glue Kafka connection not found"
  exit 1
fi

echo "✅ Glue Kafka connection exists: $GLUE_CONNECTION"

# Test connection
echo "Testing Glue connection..."
aws glue test-connection --connection-name "$GLUE_CONNECTION" --query 'Status' --output text

echo "✅ Connectivity test completed"