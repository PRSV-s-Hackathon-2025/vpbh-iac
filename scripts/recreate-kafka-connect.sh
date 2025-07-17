#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Set variables
CONNECTOR_NAME="vpbh-bigdata-cluster-kinesis-sink"
REGION="ap-southeast-1"
KAFKA_CONNECT_VERSION="2.7.1"

# Fix SSL certificate issues
export AWS_CA_BUNDLE=/etc/ssl/cert.pem

echo "Using Kafka Connect version: $KAFKA_CONNECT_VERSION"

# Get connector ARN
echo "Getting connector ARN..."
CONNECTOR_ARN=$(aws kafkaconnect list-connectors --region "$REGION" --query "connectors[?connectorName=='$CONNECTOR_NAME'].connectorArn" --output text)

if [ ! -z "$CONNECTOR_ARN" ]; then
  echo "Deleting existing connector: $CONNECTOR_ARN"
  aws kafkaconnect delete-connector --connector-arn "$CONNECTOR_ARN" --region "$REGION"
  
  # Wait for deletion to complete
  echo "Waiting for connector deletion to complete..."
  sleep 60
fi

# Create a new connector with minimal configuration
echo "Creating new connector..."
aws kafkaconnect create-connector \
  --connector-name "$CONNECTOR_NAME" \
  --connector-configuration '{"connector.class":"com.amazon.kinesis.kafka.connect.KinesisSinkConnector","tasks.max":"1","topics":"transactions","aws.region":"ap-southeast-1","kinesis.stream":"vpbh-bigdata-cluster-transactions","batch.size":"100","batch.max.size.bytes":"1048576","transforms":"LocationNormalizer","transforms.LocationNormalizer.type":"org.apache.kafka.connect.transforms.InsertField$Value","transforms.LocationNormalizer.static.field":"location_normalized","transforms.LocationNormalizer.static.value":"normalized_location"}' \
  --kafka-cluster '{"apacheKafkaCluster":{"bootstrapServers":"pkc-312o0.ap-southeast-1.aws.confluent.cloud:9092","vpc":{"subnets":["subnet-0061e3fc5bb9d2dfd","subnet-01619ef3d7131f515"],"securityGroups":["sg-0f800605cd9dd64ff"]}}}' \
  --kafka-cluster-client-authentication '{"authenticationType":"NONE"}' \
  --kafka-cluster-encryption-in-transit '{"encryptionType":"TLS"}' \
  --plugins '[{"customPlugin":{"customPluginArn":"arn:aws:kafkaconnect:ap-southeast-1:955228589631:custom-plugin/vpbh-bigdata-cluster-kinesis-sink-plugin/728c731a-c3f9-44d1-a564-e56abf42af84-4","revision":1}}]' \
  --capacity '{"autoScaling":{"mcuCount":1,"minWorkerCount":1,"maxWorkerCount":2,"scaleInPolicy":{"cpuUtilizationPercentage":20},"scaleOutPolicy":{"cpuUtilizationPercentage":80}}}' \
  --service-execution-role-arn "arn:aws:iam::955228589631:role/vpbh-bigdata-cluster-kafka-connect-role" \
  --log-delivery '{"workerLogDelivery":{"cloudWatchLogs":{"enabled":true,"logGroup":"/aws/kafka-connect/vpbh-bigdata-cluster-kinesis-sink"}}}' \
  --kafka-connect-version "$KAFKA_CONNECT_VERSION" \
  --region "$REGION"

echo "Connector creation initiated."