#!/bin/bash

# Set script to exit on first error
set -e

# Load the YAML configuration file for service accounts and RBAC settings
CONFIG_FILE="sa_rbac_config.yaml"
KUBE_DIR="/etc/kubernetes/pki" # Directory where ca.crt is stored, If run on minikube use= "$HOME/.minikube"
KUBECONFIGS_DIR="$HOME/.kube/kubeconfigs"
NAMESPACE="default"

# Ensure kubeconfig directory exists
sudo mkdir -p ${KUBECONFIGS_DIR}

# Change ownership to the ${KUBECONFIGS_DIR}
sudo chown -R $(whoami):$(whoami) ${KUBECONFIGS_DIR}

# Set appropriate permissions for the directory
sudo chmod 700 ${KUBECONFIGS_DIR}

# Extract the cluster's server URL from the existing kubeconfig
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# Note: uncomment and use the CA_DATA command below if the CA certificate is clearly displayed on your "$HOME/.kube/config" file hence, you can comment the CA_CERT_FILE section, else continue as shown using the CA_CERT_FILE.  
#CA_DATA=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}') 

# Base64 encode the CA certificate from the ca.crt file
CA_CERT_FILE="${KUBE_DIR}/ca.crt"
sudo chown $(whoami):$(whoami) ${CA_CERT_FILE}
CA_DATA=$(cat ${CA_CERT_FILE} | base64 | tr -d '\n')

# Function to create a service account in the Kubernetes cluster
function create_service_account {
    local USER=$1

    echo "Creating service account for user: $USER"

    # Create the service account
    kubectl create serviceaccount ${USER} --namespace=${NAMESPACE} || true

    echo "Service account created for user: $USER"
}

# Function to generate a token for the service account using the TokenRequest API
function generate_sa_token {
    local USER=$1

    echo "Generating token for service account: $USER"

    # Generate a token for the service account
    SA_TOKEN=$(kubectl create token ${USER} --duration=24h --namespace=${NAMESPACE})

    echo "Token generated for service account: $USER"
}

# Function to create a kubeconfig file for the service account
function create_kubeconfig {
    local USER=$1

    echo "Creating kubeconfig for service account: $USER"

    KUBECONFIG_FILE=${KUBECONFIGS_DIR}/${USER}.kubeconfig

    # Create the kubeconfig file with the necessary details
    cat <<EOF > ${KUBECONFIG_FILE}
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CA_DATA}
    server: ${CLUSTER_SERVER}
contexts:
- name: ${USER}-context
  context:
    cluster: ${CLUSTER_NAME}
    namespace: ${NAMESPACE}
    user: ${USER}
current-context: ${USER}-context
preferences: {}
users:
- name: ${USER}
  user:
    token: ${SA_TOKEN}
EOF

    echo "Kubeconfig created for service account $USER"
}

# Function to create a ClusterRole and ClusterRoleBinding for the service account
function create_rbac_policy {
    local USER=$1
    local ROLE=$2
    local PERMISSIONS=$3

    echo "Creating ClusterRole and ClusterRoleBinding for service account: $USER with role: $ROLE"

    # Create the ClusterRole
    cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${ROLE}
rules:
${PERMISSIONS}
EOF

    # Create the ClusterRoleBinding for the service account
    cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${USER}-binding
subjects:
- kind: ServiceAccount
  name: ${USER}
  namespace: ${NAMESPACE}
roleRef:
  kind: ClusterRole
  name: ${ROLE}
  apiGroup: rbac.authorization.k8s.io
EOF

    echo "ClusterRole and ClusterRoleBinding created for service account: $USER"
}

# Parse permissions from YAML
function get_permissions {
    local USER=$1
    yq e ".users[] | select(.name == \"$USER\") | .permissions" $CONFIG_FILE
}

# Handle service accounts configuration
for USER in $(yq e '.users[].name' $CONFIG_FILE); do
  ROLE=$(yq e ".users[] | select(.name == \"$USER\") | .role" $CONFIG_FILE)
  PERMISSIONS=$(get_permissions $USER)

  echo "Processing service account $USER with role $ROLE"

  # Step 1: Create the service account
  create_service_account $USER

  # Step 2: Generate a token for the service account
  generate_sa_token $USER

  # Step 3: Create the kubeconfig file
  create_kubeconfig $USER

  # Step 4: Create ClusterRole and ClusterRoleBinding
  create_rbac_policy $USER $ROLE "$PERMISSIONS"

done

echo "All service accounts and RBAC resources created successfully!"
