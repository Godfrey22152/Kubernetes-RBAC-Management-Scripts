#!/bin/bash

# Set script to exit on first error
set -e

# Load the YAML configuration file for service accounts and RBAC settings
CONFIG_FILE="sa_rbac_config.yaml"
KUBECONFIGS_DIR="$HOME/.kube/kubeconfigs"
NAMESPACE="default"

# Ensure the KUBECONFIGS_DIR exists before deletion
if [ -d "$KUBECONFIGS_DIR" ]; then
  echo "Kubeconfig directory found at ${KUBECONFIGS_DIR}. Proceeding with deletion."
else
  echo "Kubeconfig directory does not exist. Exiting."
  exit 1
fi

# Function to delete a service account in the Kubernetes cluster
function delete_service_account {
    local USER=$1

    echo "Deleting service account for user: $USER"
    
    # Delete the service account
    kubectl delete serviceaccount ${USER} --namespace=${NAMESPACE} || true

    echo "Service account deleted for user: $USER"
}

# Function to delete the kubeconfig file for the service account
function delete_kubeconfig {
    local USER=$1
    KUBECONFIG_FILE=${KUBECONFIGS_DIR}/${USER}.kubeconfig

    if [ -f "$KUBECONFIG_FILE" ]; then
      echo "Deleting kubeconfig for service account: $USER"
      sudo rm -f ${KUBECONFIG_FILE}
      echo "Kubeconfig deleted for service account: $USER"
    else
      echo "No kubeconfig file found for user: $USER"
    fi
}

# Function to delete the ClusterRole and ClusterRoleBinding for the service account
function delete_rbac_policy {
    local USER=$1
    local ROLE=$2

    echo "Deleting ClusterRole and ClusterRoleBinding for user: $USER"

    # Delete the ClusterRoleBinding
    kubectl delete clusterrolebinding ${USER}-binding || true

    # Delete the ClusterRole
    kubectl delete clusterrole ${ROLE} || true

    echo "ClusterRole and ClusterRoleBinding deleted for user: $USER"
}

# Handle deletion of service accounts configuration
for USER in $(yq e '.users[].name' $CONFIG_FILE); do
  ROLE=$(yq e ".users[] | select(.name == \"$USER\") | .role" $CONFIG_FILE)

  echo "Processing deletion for service account $USER with role $ROLE"

  # Step 1: Delete the service account
  delete_service_account $USER

  # Step 2: Delete the kubeconfig file
  delete_kubeconfig $USER

  # Step 3: Delete ClusterRole and ClusterRoleBinding
  delete_rbac_policy $USER $ROLE

done

# Clean up the KUBECONFIGS_DIR
if [ -d "$KUBECONFIGS_DIR" ]; then
  echo "Cleaning up kubeconfig directory: ${KUBECONFIGS_DIR}"
  sudo rm -rf ${KUBECONFIGS_DIR}
  echo "Kubeconfig directory deleted."
else
  echo "No kubeconfig directory found. Skipping cleanup."
fi

echo "All service accounts, RBAC resources, and kubeconfig files have been deleted successfully!"
