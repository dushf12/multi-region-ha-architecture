#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI not found. Installing..."
    pip install awscli
fi

# Configure AWS CLI (set your credentials)
echo "Configuring AWS CLI..."
aws configure

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply Terraform configuration to set up infrastructure
echo "Applying Terraform configuration..."
terraform apply -auto-approve
