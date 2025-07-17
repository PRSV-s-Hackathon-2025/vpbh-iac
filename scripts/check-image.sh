#!/bin/bash

# Check what's in ECR
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "Checking ECR repository: $ECR_URL"

# List images in ECR
aws ecr describe-images --repository-name vpbh-bigdata-api --region ap-southeast-1

# Check local Docker images
echo -e "\nLocal Docker images:"
docker images | grep vpbh-bigdata-api

# Inspect the pushed image
echo -e "\nInspecting pushed image:"
docker manifest inspect $ECR_URL:latest 2>/dev/null || echo "Cannot inspect manifest"