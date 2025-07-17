#!/bin/bash
set -e

# List files in the S3 bucket
echo "Listing files in S3 bucket..."
aws s3 ls s3://prsv-vpb-hackathon-transaction-data-processed/ --recursive | head -20