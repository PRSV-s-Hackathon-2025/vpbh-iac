resource "aws_iam_role" "glue_streaming" {
  name = "${var.cluster_name}-glue-streaming-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_streaming.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_streaming_policy" {
  name = "${var.cluster_name}-glue-streaming-policy"
  role = aws_iam_role.glue_streaming.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${var.s3_bucket_arn}",
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_security_group" "glue_streaming" {
  name_prefix = "${var.cluster_name}-glue-streaming"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_s3_object" "glue_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/kafka-to-s3-streaming.py"
  content = templatefile("${path.module}/kafka-to-s3-streaming.py", {
    kafka_bootstrap_servers = var.kafka_bootstrap_servers
    s3_bucket_name         = var.s3_bucket_name
  })

  tags = var.tags
}

resource "aws_glue_job" "streaming" {
  name         = "${var.cluster_name}-kafka-streaming"
  role_arn     = aws_iam_role.glue_streaming.arn
  glue_version = "4.0"
  worker_type  = "G.1X"
  number_of_workers = 2

  command {
    name            = "gluestreaming"
    script_location = "s3://${var.s3_bucket_name}/${aws_s3_object.glue_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--enable-metrics"                   = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"           = "s3://${var.s3_bucket_name}/spark-logs/"
    "--enable-job-insights"             = "true"
    "--enable-observability-metrics"    = "true"
    "--enable-glue-datacatalog"         = "true"
    "--kafka-bootstrap-servers"         = var.kafka_bootstrap_servers
    "--s3-bucket-name"                  = var.s3_bucket_name
  }

  connections = [aws_glue_connection.kafka.name]

  tags = var.tags
}

resource "aws_glue_connection" "kafka" {
  name = "${var.cluster_name}-kafka-connection"

  connection_properties = {
    KAFKA_BOOTSTRAP_SERVERS = var.kafka_bootstrap_servers
  }

  connection_type = "KAFKA"

  physical_connection_requirements {
    availability_zone      = var.availability_zones[0]
    security_group_id_list = [aws_security_group.glue_streaming.id, var.kafka_security_group_id]
    subnet_id              = var.private_subnet_ids[0]
  }

  tags = var.tags
}