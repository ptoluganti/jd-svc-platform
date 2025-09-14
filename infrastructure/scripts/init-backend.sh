#!/bin/bash

# Initialize Terraform Backend for JD Services Platform
set -e

LOCATION="East US"
BACKEND_RESOURCE_GROUP="jd-svc-platform-tfstate-rg"
BACKEND_STORAGE_ACCOUNT="jdsvcplatformtfstate"
BACKEND_CONTAINER="tfstate"

echo "Creating Terraform backend resources..."

# Create resource group for Terraform state
az group create --name $BACKEND_RESOURCE_GROUP --location "$LOCATION"

# Create storage account for Terraform state
az storage account create \
  --name $BACKEND_STORAGE_ACCOUNT \
  --resource-group $BACKEND_RESOURCE_GROUP \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $BACKEND_RESOURCE_GROUP --account-name $BACKEND_STORAGE_ACCOUNT --query '[0].value' -o tsv)

# Create storage container
az storage container create \
  --name $BACKEND_CONTAINER \
  --account-name $BACKEND_STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

echo "Terraform backend resources created successfully!"
echo "Backend configuration:"
echo "  Resource Group: $BACKEND_RESOURCE_GROUP"
echo "  Storage Account: $BACKEND_STORAGE_ACCOUNT"
echo "  Container: $BACKEND_CONTAINER"
echo ""
echo "Use this configuration in your Terraform backend blocks."