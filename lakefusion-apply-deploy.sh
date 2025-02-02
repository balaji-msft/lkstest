#!/bin/bash

# Check if the correct number of arguments are passed
if [ "$#" -lt 15 ] || [ "$#" -gt 16 ]; then
  echo "Usage: $0 CLOUD_PROVIDER DATABRICKS_DAPI DATABRICKS_HOST DATABRICKS_OIDC_CLIENT_ID DATABRICKS_OIDC_CLIENT_SECRET DEPLOYMENT_ENV SQL_DBNAME SQL_USERNAME SQL_PASSWORD ACR_USERNAME ACR_PASSWORD ACR_EMAIL_ADDRESS CUSTOMER_ORGANIZATION WORKSPACE_ID storage_root_path [LOCATION] [LF_DOCKER_TAG]"
  exit 1
fi

# Assign the arguments to variables
CLOUD_PROVIDER=$1
DATABRICKS_DAPI=$2
DATABRICKS_HOST=$3
DATABRICKS_OIDC_CLIENT_ID=$4
DATABRICKS_OIDC_CLIENT_SECRET=$5
DEPLOYMENT_ENV=$6
SQL_DBNAME=$7
SQL_USERNAME=$8
SQL_PASSWORD=${9}
ACR_USERNAME=${10}
ACR_PASSWORD=${11}
ACR_EMAIL_ADDRESS=${12}
CUSTOMER_ORGANIZATION=${13}
WORKSPACE_ID=${14}
# If location is not provided, default to "eastus"
storage_root_path=${15}
LOCATION=${16:-eastus}
LF_DOCKER_TAG="${17:-latest}"

# Check for valid CLOUD_PROVIDER argument
if [ "$CLOUD_PROVIDER" != "azure" ]; then
  echo "Invalid CLOUD_PROVIDER. Currently only 'azure' is supported."
  exit 1
fi

# Change directory based on cloud provider
echo "Switching to $CLOUD_PROVIDER directory..."
cd "$CLOUD_PROVIDER" || { echo "Failed to switch to $CLOUD_PROVIDER directory"; exit 1; }

# Run Terraform commands
echo "Running Terraform init..."
terraform init || { echo "Terraform init failed"; exit 1; }

echo "Running Terraform plan..."
terraform plan \
  -var="workspace_id=$WORKSPACE_ID" \
  -var="mysql_admin_login=$SQL_USERNAME" \
  -var="mysql_admin_password=$SQL_PASSWORD" \
  -var="mysql_db_name=$SQL_DBNAME" \
  -var="location=$LOCATION" \
  -var="host=$DATABRICKS_HOST" \
  -var="storage_root_path=$storage_root_path" \
  -var="token=$DATABRICKS_DAPI" \
  -out=lakefusion_resources.out || { echo "Terraform plan failed"; exit 1; }

echo "Running Terraform apply..."
terraform apply "lakefusion_resources.out" || { echo "Terraform apply failed"; exit 1; }

# Extract the resource group and AKS cluster name from Terraform output
RESOURCE_GROUP=$(terraform output -raw resource_group_name) || { echo "Failed to extract resource group"; exit 1; }
AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name) || { echo "Failed to extract AKS cluster name"; exit 1; }
SQL_SERVER=$(terraform output -raw mysql_server_url) || { echo "Failed to extract SQL server URL"; exit 1; }

# Use Azure CLI to get AKS credentials and configure kubectl
echo "Configuring kubectl using Azure CLI..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing || { echo "Failed to configure kubectl"; exit 1; }

# Verify connection to the Kubernetes cluster
echo "Verifying kubectl connection..."
kubectl get nodes || { echo "kubectl connection verification failed"; exit 1; }

# After Kubernetes connection is established, trigger deploy-services.sh
echo "Triggering deploy-services.sh..."

echo "Switching to deployment yamls directory..."
cd ../../deployment_ymls || { echo "Failed to switch to deployment yamls directory"; exit 1; }

./deploy-services.sh $DATABRICKS_DAPI $DATABRICKS_HOST $DATABRICKS_OIDC_CLIENT_ID $DATABRICKS_OIDC_CLIENT_SECRET $DEPLOYMENT_ENV $SQL_DBNAME $SQL_SERVER $SQL_USERNAME $SQL_PASSWORD $ACR_USERNAME $ACR_PASSWORD $ACR_EMAIL_ADDRESS $CUSTOMER_ORGANIZATION $LF_DOCKER_TAG || { echo "deploy-services.sh failed"; exit 1; }
