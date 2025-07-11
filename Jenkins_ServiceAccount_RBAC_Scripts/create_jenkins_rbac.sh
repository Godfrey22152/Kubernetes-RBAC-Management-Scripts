#!/bin/bash

# Define Resources
NAMESPACE="webapps"
ROLE="jenkins-role"
ROLEBINDING="jenkins-rolebinding"
SECRET="jenkins-secret"
SERVICEACCOUNT="jenkins"
RBAC_CONFIG_FILE="jenkins_rbac_config.yaml"
PROCESS_NAME="Jenkins ServiceAccount"

# Check if namespace exists, if not, create it
kubectl get namespace $NAMESPACE >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Namespace $NAMESPACE does not exist. Creating namespace..."
  kubectl create namespace $NAMESPACE
else
  echo "Namespace $NAMESPACE already exists."
fi

# Create the resources using the Jenkins_rbac_config.yaml file
echo "Creating $PROCESS_NAME, Role, RoleBinding, and Secret..."
kubectl apply -f $RBAC_CONFIG_FILE

# Verify the creation of the ServiceAccount, Role, and RoleBinding
kubectl get serviceaccount $SERVICEACCOUNT -n $NAMESPACE
kubectl get role $ROLE -n $NAMESPACE
kubectl get rolebinding $ROLEBINDING -n $NAMESPACE

# Wait for the secret to be created
echo "Waiting for the $SECRET secret to be created..."
sleep 5

# Get the secret for the service account and display it
SECRET_NAME=$(kubectl get secret -n $NAMESPACE | grep $SECRET | awk '{print $1}')

if [ -z "$SECRET_NAME" ]; then
  echo "Error: Could not find the $SECRET secret for the $PROCESS_NAME."
else
  echo "$PROCESS_NAME secret created: $SECRET_NAME"

  # Retrieve the secret token
  SECRET_TOKEN=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.token}' | base64 --decode)

  if [ -z "$SECRET_TOKEN" ]; then
    echo "Error: Could not retrieve the token from the secret."
  else
    echo "Secret token for the $PROCESS_NAME:"
    echo "$SECRET_TOKEN"
  fi
fi

echo "$PROCESS_NAME and RBAC resources created successfully!"
