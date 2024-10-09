#!/bin/bash

# Set script to exit on first error
set -e

# Load the YAML configuration file for users and groups
CONFIG_FILE="rbac_config.yaml"
KUBE_DIR="/etc/kubernetes/pki"  # Kubernetes PKI directory
KUBECONFIG_DIR="$HOME/.kube/config"
NAMESPACE="default"

# Delete user certificates and directories
function delete_user_cert {
    local USER=$1
    local GROUP=$2

    GROUP_KUBE_DIR="${KUBE_DIR}/${GROUP}"

    echo "Deleting certificates for user: $USER in group: $GROUP"

    # Delete user certificates
    sudo rm -f ${GROUP_KUBE_DIR}/${USER}-key.pem
    sudo rm -f ${GROUP_KUBE_DIR}/${USER}.csr
    sudo rm -f ${GROUP_KUBE_DIR}/${USER}.crt
    sudo rm -rf ${GROUP_KUBE_DIR}

    echo "Certificates deleted for user $USER in group $GROUP"
}

# Remove the user's kubeconfig entry
function delete_kubeconfig {
    local USER=$1
    echo "Deleting kubeconfig for user: $USER"
    
    # Unset user credentials and context from kubeconfig
    kubectl config unset users.${USER}
    kubectl config unset contexts.${USER}-context
    
    echo "Kubeconfig deleted for user $USER"
}

# Delete ClusterRole and ClusterRoleBinding for the user or group
function delete_rbac_policy {
    local SUBJECT_NAME=$1
    local ROLE=$2
    local KIND=$3  # 'User' or 'Group'

    echo "Deleting ClusterRoleBinding for $SUBJECT_NAME"
    kubectl delete clusterrolebinding ${SUBJECT_NAME}-binding --ignore-not-found

    echo "Deleting ClusterRole for role: $ROLE"
    kubectl delete clusterrole ${ROLE} --ignore-not-found
}

# Handle users configuration
for USER in $(yq e '.users[].name' $CONFIG_FILE); do
    ROLE=$(yq e ".users[] | select(.name == \"$USER\") | .role" $CONFIG_FILE)
    
    echo "Deleting resources for user $USER with role $ROLE"
    delete_user_cert $USER "users"
    delete_kubeconfig $USER
    delete_rbac_policy $USER $ROLE "User"
done

# Handle groups configuration
for GROUP in $(yq e '.groups[].name' $CONFIG_FILE); do
    ROLE=$(yq e ".groups[] | select(.name == \"$GROUP\") | .role" $CONFIG_FILE)
    
    echo "Deleting resources for group $GROUP with role $ROLE"
    delete_rbac_policy $GROUP $ROLE "Group"

    # Handle users within groups and delete their resources individually
    for USER in $(yq e ".groups[] | select(.name == \"$GROUP\") | .users[]" $CONFIG_FILE); do
        echo "Deleting resources for user $USER in group $GROUP"
        delete_user_cert $USER $GROUP
        delete_kubeconfig $USER
        delete_rbac_policy $USER $ROLE "User"
    done
done

echo "All resources deleted successfully."
