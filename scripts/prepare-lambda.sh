#!/bin/bash

# Navigate to the kinesis-firehose module directory
cd modules/kinesis-firehose

# Create a temporary directory
mkdir -p tmp

# Copy the Python file to the temporary directory
cp location-normalizer.py tmp/

# Create the ZIP file
cd tmp
zip -r ../location-normalizer.zip location-normalizer.py
cd ..

# Clean up
rm -rf tmp

echo "Created location-normalizer.zip successfully"