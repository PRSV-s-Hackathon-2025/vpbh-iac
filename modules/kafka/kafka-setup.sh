#!/bin/bash
sudo yum update -y
sudo yum install -y java-11-amazon-corretto

# Download and install Kafka
cd /opt
sudo wget https://archive.apache.org/dist/kafka/3.5.0/kafka_2.13-3.5.0.tgz
sudo tar -xzf kafka_2.13-3.5.0.tgz
sudo mv kafka_2.13-3.5.0 kafka
sudo chown -R ec2-user:ec2-user kafka

# Configure Zookeeper
cat > /opt/kafka/config/zookeeper.properties << EOF
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0
admin.enableServer=false
server.${kafka_id}=0.0.0.0:2888:3888
EOF

# Configure Kafka
cat > /opt/kafka/config/server.properties << EOF
broker.id=${kafka_id}
listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/tmp/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
EOF

# Create systemd services
sudo tee /etc/systemd/system/zookeeper.service > /dev/null << 'EOF'
[Unit]
Description=Apache Zookeeper
After=network.target

[Service]
Type=simple
User=ec2-user
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/kafka.service > /dev/null << 'EOF'
[Unit]
Description=Apache Kafka
After=zookeeper.service

[Service]
Type=simple
User=ec2-user
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable zookeeper kafka
sudo systemctl start zookeeper
sleep 10
sudo systemctl start kafka

# Create transaction topic
sleep 30
/opt/kafka/bin/kafka-topics.sh --create --topic transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1