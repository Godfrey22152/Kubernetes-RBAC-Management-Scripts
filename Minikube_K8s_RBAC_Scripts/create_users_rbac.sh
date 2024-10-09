#!/bin/bash

# Set script to exit on first error
set -e

# Load the YAML configuration file for users and groups
CONFIG_FILE="rbac_config.yaml"
KUBE_DIR="$HOME/.minikube"
KUBECONFIG_DIR="$HOME/.kube/config"
NAMESPACE="default"

# Generate Kubernetes user certificate on the Minikube node
function create_user_cert {
    local USER=$1
    local GROUP=$2

    # Set paths on the Minikube node for PKI and kubeconfig directories
    GROUP_KUBE_DIR="${KUBE_DIR}/${GROUP}"

    # Create directories for user certificates
    sudo mkdir -p ${GROUP_KUBE_DIR}

    echo "Creating certificate for user: $USER in group: $GROUP"

    # Generate certificates
    sudo openssl genrsa -out ${GROUP_KUBE_DIR}/${USER}-key.pem 2048
    sudo openssl req -new -key ${GROUP_KUBE_DIR}/${USER}-key.pem -out ${GROUP_KUBE_DIR}/${USER}.csr -subj "/CN=${USER}/O=${GROUP}"
    sudo openssl x509 -req -in ${GROUP_KUBE_DIR}/${USER}.csr -CA ${KUBE_DIR}/ca.crt -CAkey ${KUBE_DIR}/ca.key -CAcreateserial -out ${GROUP_KUBE_DIR}/${USER}.crt -days 365

    # Change ownership
    sudo chown $(whoami):$(whoami) ${GROUP_KUBE_DIR}/${USER}-key.pem
    sudo chown $(whoami):$(whoami) ${GROUP_KUBE_DIR}/${USER}.crt

    echo "Certificate created for user $USER in group $GROUP"
}

# Generate a kubeconfig file for the user
function create_kubeconfig {
    local USER=$1
    local GROUP=$2

    echo "Creating kubeconfig for user: $USER in group: $GROUP"

    # Set up kubeconfig
    kubectl config set-credentials ${USER} --client-certificate=${GROUP_KUBE_DIR}/${USER}.crt --client-key=${GROUP_KUBE_DIR}/${USER}-key.pem --embed-certs=true --kubeconfig=${KUBECONFIG_DIR}
    kubectl config set-context ${USER}-context --cluster=minikube --namespace=${NAMESPACE} --user=${USER} --kubeconfig=${KUBECONFIG_DIR}

    echo "Kubeconfig created for user $USER in group $GROUP at ${GROUP_KUBECONFIG_DIR}/${USER}.kubeconfig"
}

# Create a ClusterRole and ClusterRoleBinding for the user or group
function create_rbac_policy {
    local SUBJECT_NAME=$1
    local ROLE=$2
    local PERMISSIONS=$3
    local KIND=$4  # The kind can be 'User' or 'Group'

    echo "Creating ClusterRole and ClusterRoleBinding for $SUBJECT_NAME with role: $ROLE"

    # Create the ClusterRole
    cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${ROLE}
rules:
${PERMISSIONS}
EOF

    # Create the ClusterRoleBinding, binding either User or Group
    cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${SUBJECT_NAME}-binding
subjects:
- kind: ${KIND}  # Could be 'User' or 'Group'
  name: ${SUBJECT_NAME}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: ${ROLE}
  apiGroup: rbac.authorization.k8s.io
EOF
}

# Parse permissions from YAML
function get_permissions {
    local SUBJECT=$1
    local TYPE=$2
    yq e ".${TYPE}[] | select(.name == \"$SUBJECT\") | .permissions" $CONFIG_FILE
}

# Handle users configuration
for USER in $(yq e '.users[].name' $CONFIG_FILE); do
  ROLE=$(yq e ".users[] | select(.name == \"$USER\") | .role" $CONFIG_FILE)
  PERMISSIONS=$(get_permissions $USER "users")

  echo "Processing user $USER with role $ROLE"
  create_user_cert $USER "users"  # User certificates are saved in $HOME/.minikube/users directory
  create_kubeconfig $USER "users"
  create_rbac_policy $USER $ROLE "$PERMISSIONS" "User"
done

# Handle groups configuration
for GROUP in $(yq e '.groups[].name' $CONFIG_FILE); do
  ROLE=$(yq e ".groups[] | select(.name == \"$GROUP\") | .role" $CONFIG_FILE)
  PERMISSIONS=$(get_permissions $GROUP "groups")

  echo "Processing group $GROUP with role $ROLE"
  create_rbac_policy $GROUP $ROLE "$PERMISSIONS" "Group"  # Create a ClusterRoleBinding for the group

  # Handle users within groups and bind them individually to the role
  for USER in $(yq e ".groups[] | select(.name == \"$GROUP\") | .users[]" $CONFIG_FILE); do
    echo "Processing user $USER in group $GROUP"
    create_user_cert $USER $GROUP  # Create user certificates in group-specific subdirectory
    create_kubeconfig $USER $GROUP  # Create kubeconfig in group-specific subdirectory $HOME/.kube/config
    create_rbac_policy $USER $ROLE "$PERMISSIONS" "User"  # Bind each user to the group role individually
  done
done

echo "All resources created successfully.!!!"
