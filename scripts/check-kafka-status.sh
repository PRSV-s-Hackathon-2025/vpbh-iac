#!/bin/bash

echo "=== Checking Kafka Cluster Status ==="

# Get Kafka instance IPs
KAFKA_IPS=(10.0.1.229 10.0.3.165 10.0.2.218)
PRODUCER_IP=10.0.1.89

echo "1. Checking Kafka services on each node..."
for ip in "${KAFKA_IPS[@]}"; do
    echo "Checking Kafka node: $ip"
    aws ssm send-command \
        --instance-ids $(aws ec2 describe-instances --filters "Name=private-ip-address,Values=$ip" --query 'Reservations[0].Instances[0].InstanceId' --output text) \
        --document-name "AWS-RunShellScript" \
        --parameters 'commands=["systemctl status kafka --no-pager", "systemctl status zookeeper --no-pager"]' \
        --query 'Command.CommandId' --output text
done

echo -e "\n2. Checking Kafka topics..."
aws ssm send-command \
    --instance-ids $(aws ec2 describe-instances --filters "Name=private-ip-address,Values=${KAFKA_IPS[0]}" --query 'Reservations[0].Instances[0].InstanceId' --output text) \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092"]' \
    --query 'Command.CommandId' --output text

echo -e "\n3. Checking producer service..."
aws ssm send-command \
    --instance-ids $(aws ec2 describe-instances --filters "Name=private-ip-address,Values=$PRODUCER_IP" --query 'Reservations[0].Instances[0].InstanceId' --output text) \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["systemctl status transaction-producer --no-pager", "tail -20 /var/log/messages | grep python"]' \
    --query 'Command.CommandId' --output text

echo -e "\n4. Checking message count in Kafka topic..."
aws ssm send-command \
    --instance-ids $(aws ec2 describe-instances --filters "Name=private-ip-address,Values=${KAFKA_IPS[0]}" --query 'Reservations[0].Instances[0].InstanceId' --output text) \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["/opt/kafka/bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic transactions --time -1"]' \
    --query 'Command.CommandId' --output text

echo -e "\nCommand IDs returned above. Wait 30 seconds then check results with:"
echo "aws ssm get-command-invocation --command-id <COMMAND_ID> --instance-id <INSTANCE_ID>"