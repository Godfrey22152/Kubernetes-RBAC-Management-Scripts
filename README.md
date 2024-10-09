# Kubernetes Role-Based Access Control (RBAC) Management Scripts

## Project Overview

This project provides a comprehensive toolkit for automating the installation and management of Kubernetes clusters using `RBAC`, including user and groups management and RBAC configuration. The toolkit consists of several scripts organized into directories, each designed to facilitate how to automate and manage Users and Groups in a kubernetes cluster using `RBAC`.

## Directory Key Features

### K8s Cluster Kubeadm Setup:- Key Features
- Automates the setup of multinode Kubernetes cluster using kubeadm.
- A detailed `README.md` file for manual setup.

### Kubernetes RBAC Management:- Key Features
- Automates the creation of Kubernetes users and RBAC policies.
- Generates user certificates and kubeconfig files for secure access.
- Supports group management with associated roles and permissions.
- Configurable via a YAML file for easy adjustments.

### Minikube K8s RBAC Scripts:- Key Features
- Automates the creation of Kubernetes users and RBAC policies.
- Generates user certificates and kubeconfig files for secure access.
- Supports group management with associated roles and permissions.
- Configurable via a YAML file for easy adjustments.

### K8s Service Account RBAC Scripts:- Key Features
- Automates the creation of Kubernetes Service Accounts and RBAC policies.
- Generates tokens for Service Accounts using the TokenRequest API.
- Creates kubeconfig files for Service Accounts for easy access.
- Supports defining user roles and permissions through a YAML configuration file.
- Handles permissions parsing from YAML for flexible RBAC configurations.

### Jenkins Service Account RBAC Scripts:- Key Features
- Automates the creation of a Kubernetes namespace for Jenkins.
- Creates a Jenkins ServiceAccount along with its Role and RoleBinding.
- Verifies the creation of resources and retrieves the associated secret token.
- Provides error handling and user-friendly messages throughout the process.

## Table of Contents
- [Project Overview](#project-overview)
- [Directory Key Features](#directory-key-features)
- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
  - [K8s Cluster Kubeadm Setup](#K8s-Cluster-Kubeadm-Setup)
  - [K8s RBAC Management](#K8s-RBAC-Management)
  - [Minikube K8s RBAC Scripts](#Minikube-K8s-RBAC-Scripts)
  - [K8s ServiceAccount RBAC Scripts](#K8s-ServiceAccount-RBAC-Scripts)
  - [Jenkins ServiceAccount RBAC Scripts](#Jenkins-ServiceAccount-RBAC-Scripts)
- [Installation](#installation)
- [Usage](#usage)
- [References](#references)


## Directory Structure
```plaintext
Kubernetes-RBAC-Management-Scripts/
├── K8s_Cluster_Kubeadm_Setup/
│   ├── setup_k8s.sh
│   └── README.md
├── K8s_RBAC_Management/
│   ├── rbac_config.yaml
│   ├── create_K8s_rbac.sh
│   ├── delete_K8s_rbac.sh
│   └── README.md
├── Minikube_K8s_RBAC_Scripts/
│   ├── rbac_config.yaml
│   ├── create_users_rbac.sh
│   ├── delete_users_rbac.sh
│   └── README.md
├── K8s_ServiceAccount_RBAC_Scripts/
│   ├── sa_rbac_config.yaml
│   ├── sa_create_K8s_rbac.sh
│   ├── delete_sa_resource_K8s_rbac.sh
│   └── README.md
├── Jenkins_ServicAccount_RBAC_Scripts/
│   ├── jenkins_rbac_config.yaml
│   ├── create_jenkins_rbac.sh
│   ├── delete_jenkins_rbac.sh
│   └── README.md  
└── README.md
```

## Prerequisites

### K8s Cluster Kubeadm Setup
- **Operating System**: Ubuntu 20.04 or later (other Linux distributions may work with minor modifications).
- **Networking**: Ensure that your network is configured to allow communication between Kubernetes nodes.
- Root or sudo privileges
- Basic understanding of Linux commands 
- **See README.md file in directory before running the scripts**

### K8s RBAC Management 
- Kubernetes cluster up and running
- **Kubectl Configured**: Your `kubectl` must be configured to interact with your cluster.
- **YQ (YAML Query tool)**: This tool `yq` is required to parse YAML configuration files.
- OpenSSL installed for certificate generation.
- **See README.md file in directory before running the scripts**

### Minikube K8s RBAC Scripts
- Minikube installed and running on your local machine.
- kubectl installed and configured to communicate with your Minikube cluster.
- `yq` installed for parsing YAML files.
- OpenSSL installed for certificate generation.
- A valid `rbac_config.yaml` file containing user and group configurations.
- **See README.md file in directory before running the scripts**

### K8s ServiceAccount RBAC Scripts
- Kubernetes cluster (Minikube or any Kubernetes setup).
- `kubectl` command-line tool installed and configured.
- `yq` tool for parsing YAML files.
- **See README.md file in directory before running the scripts**

### Jenkins ServiceAccount RBAC Scripts
- Kubernetes cluster (Minikube or any Kubernetes setup).
- `kubectl` command-line tool installed and configured.
- `jenkins_rbac_config.yaml` file defining the Role and RoleBinding.
- **See README.md file in directory before running the scripts**

## Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/Godfrey22152/Kubernetes-RBAC-Management-Scripts.git
   cd Kubernetes-RBAC-Management-Scripts
   ```

2. For K8s_Cluster_Kubeadm_Setup, run:
   ```bash
   cd K8s_Cluster_Kubeadm_Setup
   chmod +x setup_k8s.sh
   ./setup_k8s.sh master
   ```

3. For K8s_RBAC_Management, run:
   ```bash
   cd K8s_RBAC_Management
   sudo chmod +x create_K8s_rbac.sh
   ./create_K8s_rbac.sh
   ```

4. For Minikube_K8s_RBAC_Scripts
   ```bash
   cd Minikube_K8s_RBAC_Scripts
   sudo chmod +x create_users_rbac.sh
   ./create_users_rbac.sh
   ```

5. For K8s_ServiceAccount_RBAC_Scripts
   ```bash
   cd K8s_ServiceAccount_RBAC_Scripts
   sudo chmod +x sa_create_K8s_rbac.sh
   ./sa_create_K8s_rbac.sh
   ```

6. For Jenkins_ServicAccount_RBAC_Scripts 
   ```bash
   cd Jenkins_ServicAccount_RBAC_Scripts
   sudo chmod +x create_jenkins_rbac.sh
   ./create_jenkins_rbac.sh
   ```

## Usage
Follow the instructions in each directory's README.md file for detailed usage of the scripts provided.

## References

### General Documentation Reference
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [RBAC in Kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [YAML Parser (yq)](https://github.com/mikefarah/yq)

### Documentation Reference for Minikube K8s RBAC Scripts
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [yq Documentation](https://mikefarah.gitbook.io/yq/)
- [OpenSSL Documentation](https://www.openssl.org/docs/)

### Documentation Reference for Service Account
- [Kubernetes Service Account Documentation](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [Managing Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#:~:text=To%20create%20a%20non%2Dexpiring,with%20that%20generated%20token%20data.)

### Documentation Reference for Jenkins
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Generate Secret Token](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#:~:text=To%20create%20a%20non%2Dexpiring,with%20that%20generated%20token%20data.)