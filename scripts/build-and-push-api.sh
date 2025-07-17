#!/bin/bash
set -e

# Get ECR repository URL from Terraform output
ECR_URL=$(terraform output -raw ecr_repository_url)

if [ -z "$ECR_URL" ]; then
    echo "❌ ECR repository URL not found. Run terraform apply first."
    exit 1
fi

echo "🔗 ECR Repository URL: $ECR_URL"

# Build Go binary
echo "🔧 Building Go binary..."
cd api
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ap-southeast-1 \
  | docker login --username AWS --password-stdin $ECR_URL

# Build Docker image for AMD64 platform
echo "🐳 Building Docker image..."
docker build --platform linux/amd64 -t vpbh-bigdata-api .

# Tag image
echo "🏷️ Tagging image..."
docker tag vpbh-bigdata-api:latest $ECR_URL:latest

# Push to ECR
echo "📤 Pushing to ECR..."
docker push $ECR_URL:latest

echo "✅ Image pushed successfully: $ECR_URL:latest"
