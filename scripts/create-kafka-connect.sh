#!/bin/bash

# Set variables
CONNECTOR_NAME="vpbh-bigdata-cluster-kinesis-sink"
REGION="ap-southeast-1"
KINESIS_STREAM="vpbh-bigdata-cluster-transactions"
KAFKA_USERNAME="D7CGBNHBWIMUP4VJ"
KAFKA_PASSWORD="XdyfB3gBynCAB4ejr4BL1peQybQNb02DMIXqS/6hI2WjyI9CGoRxJb+stceObh82"
BOOTSTRAP_SERVERS="pkc-312o0.ap-southeast-1.aws.confluent.cloud:9092"

# Create a temporary file for the connector configuration
cat > connector-config.json << EOF
{
  "connectorName": "$CONNECTOR_NAME",
  "connectorConfiguration": {
    "connector.class": "com.amazon.kinesis.kafka.connect.KinesisSinkConnector",
    "tasks.max": "1",
    "topics": "transactions",
    "aws.region": "$REGION",
    "kinesis.stream": "$KINESIS_STREAM",
    "batch.size": "100",
    "batch.max.size.bytes": "1048576",
    "kafka.security.protocol": "SASL_SSL",
    "kafka.sasl.mechanism": "PLAIN",
    "kafka.sasl.jaas.config": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\\\"$KAFKA_USERNAME\\\" password=\\\"$KAFKA_PASSWORD\\\";",
    "transforms": "LocationNormalizer",
    "transforms.LocationNormalizer.type": "org.apache.kafka.connect.transforms.InsertField\$Value",
    "transforms.LocationNormalizer.static.field": "location_normalized",
    "transforms.LocationNormalizer.static.value": "normalized_location"
  },
  "kafkaCluster": {
    "apacheKafkaCluster": {
      "bootstrapServers": "$BOOTSTRAP_SERVERS",
      "vpc": {
        "subnets": [
          "subnet-0061e3fc5bb9d2dfd",
          "subnet-01619ef3d7131f515"
        ],
        "securityGroups": [
          "sg-0f800605cd9dd64ff"
        ]
      }
    }
  },
  "kafkaConnectVersion": "2.7.1",
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
  },
  "kafkaClusterClientAuthentication": {
    "authenticationType": "NONE"
  },
  "kafkaClusterEncryptionInTransit": {
    "encryptionType": "TLS"
  },
  "plugins": [
    {
      "customPlugin": {
        "customPluginArn": "arn:aws:kafkaconnect:ap-southeast-1:955228589631:custom-plugin/vpbh-bigdata-cluster-kinesis-sink-plugin/728c731a-c3f9-44d1-a564-e56abf42af84-4",
        "revision": 1
      }
    }
  ],
  "serviceExecutionRoleArn": "arn:aws:iam::955228589631:role/vpbh-bigdata-cluster-kafka-connect-role",
  "logDelivery": {
    "workerLogDelivery": {
      "cloudWatchLogs": {
        "enabled": true,
        "logGroup": "/aws/kafka-connect/vpbh-bigdata-cluster-kinesis-sink"
      }
    }
  }
}
EOF

# Delete existing connector if it exists
EXISTING_CONNECTOR=$(aws kafka-connect list-connectors --region $REGION --query "connectors[?connectorName=='$CONNECTOR_NAME'].connectorName" --output text)
if [ ! -z "$EXISTING_CONNECTOR" ]; then
  echo "Deleting existing connector: $EXISTING_CONNECTOR"
  aws kafka-connect delete-connector --connector-name $CONNECTOR_NAME --region $REGION
  
  # Wait for deletion to complete
  echo "Waiting for connector deletion to complete..."
  sleep 30
fi

# Create the connector
echo "Creating connector: $CONNECTOR_NAME"
aws kafka-connect create-connector --cli-input-json file://connector-config.json --region $REGION

# Clean up
rm connector-config.json

echo "Connector creation initiated. Check status with scripts/check-kafka-connect.sh"