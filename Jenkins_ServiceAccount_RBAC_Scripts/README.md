# Jenkins Service Account RBAC Setup for Kubernetes

This repository contains the necessary scripts and configurations to automate the creation and deletion of a **Jenkins Service Account** in the `webapps` namespace, along with the associated **RBAC (Role-Based Access Control)** policies and **Secret**.

## Files Overview

- **`jenkins_rbac_config.yaml`**: Contains the Kubernetes definitions for:
  - **ServiceAccount**: `jenkins` in the `webapps` namespace.

    ```bash
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: jenkins
      namespace: webapps
    ```

  - **Role**: `app-role`, granting access to various Kubernetes resources (pods, services, configmaps, etc.).

     ```bash
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: jenkins-role
      namespace: webapps
    rules:

      # Permissions for core API Group
      - apiGroups: [""]
        resources:
          - pods
          - configmaps
          - events
          - endpoints
          - namespaces
          - nodes
          - secrets
          - persistentvolumes
          - persistentvolumeclaims
          - resourcequotas
          - replicationcontrollers
          - services
          - serviceaccounts
        verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

      # Permissions for app API group
      - apiGroups: ["apps"]
        resources:
          - deployments
          - replicasets
          - daemonsets
          - statefulsets
        verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

      # Permissions for Networking API group
      - apiGroups: ["networking.k8s.io"]
        resources:
          - ingresses
        verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]


      # Permissions for Autoscaling API group
      - apiGroups: ["autoscaling"]
        resources:
          - horizontalpodautoscalers
        verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

      # Permissions for batch API Group
      - apiGroups: ["batch"]
        resources:
          - jobs
          - cronjobs
        verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    
    ```

  - **RoleBinding**: `app-rolebinding`, binding the role to the `jenkins` ServiceAccount.

    ```bash
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
    name: jenkins-rolebinding
    namespace: webapps
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: jenkins-role
    subjects:
    - namespace: webapps
    kind: ServiceAccount
    name: jenkins
    ```

  - **Secret**: `jenkins-secret`, containing the service account token for authentication.

    ```bash
    apiVersion: v1
    kind: Secret
    type: kubernetes.io/service-account-token
    metadata:
    name: jenkins-secret
    namespace: webapps
    annotations:
        kubernetes.io/service-account.name: jenkins
    ```

- **`create_jenkins_rbac.sh`**: A bash script that automates the creation of the Jenkins Service Account, RBAC resources, and Secret. It also retrieves and displays the service account's secret token.

- **`delete_jenkins_rbac.sh`**: A bash script to delete all resources created by the Jenkins RBAC setup (ServiceAccount, Role, RoleBinding, Secret).

## Prerequisites

Before running these scripts, ensure you have:
1. **kubectl** installed and configured to communicate with your Kubernetes cluster.
2. Proper permissions to create and delete resources in the `webapps` namespace.

## Instructions

### 1. Create Jenkins Service Account and RBAC Resources

To create the Jenkins ServiceAccount and associated RBAC resources, run the `create_jenkins_rbac.sh` script.

#### Steps:
1. Clone the repository and navigate to the project directory.

   ```bash
   git clone https://github.com/Godfrey22152/Kubernetes-RBAC-Management-Scripts.git
   && cd Kubernetes-RBAC-Management-Scripts/Jenkins_ServiceAccount_RBAC_Scripts
   ```
2. Make the `create_jenkins_rbac.sh` script executable:
   ```bash
   chmod +x create_jenkins_rbac.sh
   ```
3. Run the script:
   ```bash
   ./create_jenkins_rbac.sh
   ```

#### What the Script Does:
- It checks if the `webapps` namespace exists; if not, it creates the namespace.
- It applies the `jenkins_rbac_config.yaml` to create the **Jenkins ServiceAccount**, **Role**, **RoleBinding**, and **Secret**.
- It waits for the secret to be created and displays the token associated with the `jenkins` ServiceAccount.

#### Example Output:
```bash
Namespace webapps does not exist. Creating namespace...
namespace/webapps created
Creating Jenkins ServiceAccount, Role, RoleBinding, and Secret...
serviceaccount/jenkins created
role.rbac.authorization.k8s.io/jenkins-role created
rolebinding.rbac.authorization.k8s.io/jenkins-rolebinding created
secret/jenkins-secret created
NAME      SECRETS   AGE
jenkins   0         1s
NAME           CREATED AT
jenkins-role   2025-05-26T19:03:45Z
NAME                  ROLE                AGE
jenkins-rolebinding   Role/jenkins-role   3s
Waiting for the jenkins-secret secret to be created...
Jenkins ServiceAccount secret created: jenkins-secret
Secret token for the Jenkins ServiceAccount: <your-secret-token>
Jenkins ServiceAccount and RBAC resources created successfully!
```

### 2. Delete Jenkins Service Account and RBAC Resources

To delete all resources created by the Jenkins RBAC setup, use the `delete_jenkins_rbac.sh` script.

#### Steps:
1. Make the `delete_jenkins_rbac.sh` script executable:
   ```bash
   chmod +x delete_jenkins_rbac.sh
   ```
2. Run the script:
   ```bash
   ./delete_jenkins_rbac.sh
   ```

#### What the Script Does:
- Deletes the **Secret**, **RoleBinding**, **Role**, and **ServiceAccount** associated with Jenkins in the `webapps` namespace.
>**NOTE**: If you don't want the Namespace to be deleted, You can comment-out the section that handles the namespace deletion in the delete_jenkins_rbac.sh file.
- Verifies that each resource has been deleted successfully.

#### Example Output:
```bash
Deleting Secret jenkins-secret in namespace webapps...
secret "jenkins-secret" deleted
Deleting RoleBinding jenkins-rolebinding in namespace webapps...
rolebinding.rbac.authorization.k8s.io "jenkins-rolebinding" deleted
Deleting Role jenkins-role in namespace webapps...
role.rbac.authorization.k8s.io "jenkins-role" deleted
Deleting Jenkins ServiceAccount in namespace webapps...
serviceaccount "jenkins" deleted
Verifying that all resources are deleted...
Secret jenkins-secret deleted successfully.
RoleBinding jenkins-rolebinding deleted successfully.
Role jenkins-role deleted successfully.
ServiceAccount jenkins-secret deleted successfully.
Deleting webapps Namespace ...
webapps Namespace and all other resources have been deleted successfully.
```

## File Details

### `jenkins_rbac_config.yaml`
This file contains the Kubernetes resources for Jenkins' RBAC setup in the `webapps` namespace:

- **ServiceAccount: `jenkins`**
- **Role: `jenkins-role`** with permissions to manage various Kubernetes resources (pods, services, configmaps, etc.).
- **RoleBinding: `jenkins-rolebinding`** that binds the `jenkins-role` to the `jenkins` ServiceAccount.
- **Secret: `jenkins-secret`** containing the service account token for authentication.

### `create_jenkins_rbac.sh`

- **Purpose**: Automates the creation of Jenkins' ServiceAccount, Role, RoleBinding, and Secret.
- **Namespace**: The script creates resources in the `webapps` namespace.
- **Output**: After successful creation, the script displays the service account's secret token.

### `delete_jenkins_rbac.sh`

- **Purpose**: Automates the deletion of Jenkins' ServiceAccount, Role, RoleBinding, and Secret.
- **Namespace**: The script deletes resources in the `webapps` namespace.
- **Verification**: Verifies that the resources have been deleted.

## Notes

- The service-account-token retrieved by the `create_jenkins_rbac.sh` script can be used to authenticate the Jenkins service account in your Kubernetes cluster.
- Ensure that you securely store the token as it provides access to the specified Kubernetes resources.
- The service-account-token can be found using this command:

```bash
kubectl describe secrets <SECRET-NAME> -n <NAMESPACE>

# For Instance:
kubectl describe secrets jenkins-secret -n webapps
```
