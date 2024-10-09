
# RBAC Configuration and User Management in Kubernetes

## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Setup](#Project-Setup)
3. [Verification of Created Resources](#verification-of-created-resources)
4. [Deletion of Created Resources](#deletion-of-created-resources)
5. [Usage](#usage) 
6. [Contributing](#contributing)
7. [License](#license)

## Project Overview

This project provides a complete setup for automating the creation and managing Kubernetes RBAC (Role-Based Access Control) policies for users and groups in a Kubernetes environment. It utilizes YAML configurations and Bash scripts to create user certificates, assign roles, and set permissions for various Kubernetes resources using ClusterRoles and ClusterRoleBindings.

### Project Components

The project consists of the following key components:

- **RBAC Configuration** - `rbac_config.yaml`: Defines user and group roles and permissions in a YAML format.
- **User Creation Script** - `create_users_rbac.sh`: Automates the generation of user certificates and kubeconfig files, binding users and groups to their respective roles.
- **User Deletion Script** `delete_users_rbac.sh`: Provides functionality to cleanly remove users, groups, and their associated resources from the Kubernetes cluster using an automated bash script.

### Key Features:
- Automated user and group management in Kubernetes.
- Assign specific roles and permissions to users and groups using RBAC.
- Creation of user certificates and kubeconfig files for Kubernetes authentication.
- Ability to delete all created resources (users, groups, roles) when no longer needed.

## Project Setup

### Prerequisites

- A running Kubernetes cluster (Minikube is recommended for testing)
- `kubectl` installed and configured to communicate with your Kubernetes cluster
- `yq` installed for YAML processing
- OpenSSL for certificate generation

### Steps to Set Up the Project

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install Required Tools:**
   - Install `yq` for parsing YAML files:

     ```bash
     sudo snap install yq --classic
     ```

   - Ensure you have OpenSSL installed:

     ```bash
     sudo apt install openssl
     ```

3. **Make the user creation and deletion scripts executable:**
     
     ```bash
     sudo chmod +x create_users_rbac.sh delete_users_rbac.sh
     ```

4. **Run the `create_users_rbac.sh` Script:**

   Execute the script to create user certificates, kubeconfig entries, and set up RBAC policies:

     ```bash
     bash create_users_rbac.sh 
     # Or `./create_users_rbac.sh`
     ```

   This will:
   - Create user certificates in `/home/<user>/.minikube/<group>/` for users and groups defined in the `rbac_config.yaml` file. 
   - Create kubeconfig entries for each user.
   - Set up ClusterRoles and ClusterRoleBindings in the Kubernetes cluster.
   - After successful resource creation, the `create_users_rbac.sh`script outputs an output: "All resources created successfully.!!!" 

## Verification of Created Resources
  ### Verify Created Resources:**

   Use the following commands to verify the created resources:

   - **View Kubernetes Configuration (kubeconfig)**
     The command below opens the Kubernetes configuration file (kubeconfig) using the nano text editor with elevated permissions (using sudo).

      ```bash
       sudo nano $HOME/.kube/config
      ```
      - The `kubeconfig` file stores configuration data like cluster API server endpoints, user credentials, namespaces, and context information, allowing kubectl to interact with the Kubernetes cluster.

   - **Verify Contexts and Switch Contexts:**
      ```bash
       kubectl config get-contexts
      ```

      ```bash
       kubectl config use-context admin-user-context
      ```

    - **Verify Userss:**
      ```bash
       kubectl config get-users
      ```

    - **Verify User/Group Certificates**
      ```bash
      ls -l $HOME/.minikube/users/

      ls $HOME/.minikube/developers/

      ls $HOME/.minikube/interns

      ls $HOME/.minikube/support

      ls $HOME/.minikube/testers
      ```

   - **Verify Groups:**
     Check the created groups by reviewing the kubeconfig entries for group-based users.
     Or Check the ClusterRoleBindings:

      ```bash
       kubectl get clusterrolebindings
      ```

   - **Verify ClusterRoles:**
      ```bash
       kubectl get clusterroles
      ```

   - **Verify ClusterRoleBindings:**
      ```bash
       kubectl get clusterrolebindings
      ```

   - **Verify Specicfic ClusterRoleBinding Details of the Users/Groups in YAML Format**
     - The following command retrieves the configuration details of the ClusterRoleBinding for a specific subject (user, group, or service account), with the subject's name `${SUBJECT_NAME}-binding`a placeholder for the actual name on the `rbac_config.yaml` and displays the result in YAML format:

      ```bash
       kubectl get clusterrolebinding ${SUBJECT_NAME}-binding -o yaml
      ```
     - **For example, if the subject is named admin-user or developers, the command would become:**

      ```bash
       kubectl get clusterrolebinding admin-user-binding -o yaml

       kubectl get clusterrolebinding developers-binding -o yaml
      ```
      - **Purpose:** A ClusterRoleBinding binds a user or group to a ClusterRole, granting them specific permissions cluster-wide. This command helps inspect the admin-user-binding ClusterRoleBinding's configuration, including which users, groups, or service accounts it applies to.
      - **Output Format:** The -o yaml flag outputs the result in YAML format, which is useful for reviewing or modifying configurations in a structured, human-readable format.

   - **Verify Individual Permissions of Users:**
      ```bash
       kubectl auth can-i <VERB> <RESOURCE> --as=<USER>
      ```
     - VERB: The action the user wants to perform (e.g., get, list, create, delete).
     - RESOURCE: The resource type (e.g., pod, service, deployment).
     - --as=<USER>: Specify the user whose permissions you want to verify.

     - **Example for a specific user:**
      To verify if the user admin-user can create pods, the command would be:

      ```bash
       kubectl auth can-i create pods --as=admin-user
      ```
      - **Additional Verification for Group Permissions:**
      If you want to check the permissions of a group, you can use the --as-group=<GROUP> flag:

      ```bash
       kubectl auth can-i delete deployment --as=senior_dev_1 --as-group=developers
      ```

## Deletion of Resources

 ### Delete Resources:**

   When the resources are no longer needed, use the `delete_users_rbac.sh` script to clean up:

    ```bash
     bash delete_users_rbac.sh
    ```

   This will:
   - Remove user certificates.
   - Delete kubeconfig entries.
   - Delete the associated ClusterRoles and ClusterRoleBindings.

 ### Verify Deleted Resources:

   After deletion, verify that the resources are removed:

   - **Verify Contexts:**
     ```bash
     kubectl config get-contexts
     # This should no longer list the deleted contexts
     ```

   - **Verify Users**
     ```bash
     kubectl config get-users
     # This should no longer list the deleted users.
     ```

   - **Verify User/Group-User Certificates**
     ```bash
     ls -l $HOME/.minikube/
     # The deleted users, developers, interns, support, and testers directories should not be present.
     ```

   - **Verify ClusterRoles:**
     ```bash
     kubectl get clusterroles
     # The deleted roles should not be listed.
     ```

   - **Verify ClusterRoleBindings:**
     ```bash
     kubectl get clusterrolebindings
     # The deleted bindings should not be present.
     ```

## Usage

This project can be used in various scenarios where there is a need to manage large number of users and groups within a Kubernetes cluster, enforce security policies, and control access to specific resources.

- **Development and Staging Environments:**
  Assign roles to developers, testers, and support teams with different levels of access to resources like Pods, ConfigMaps, and Secrets.

- **Production Environments:**
  Ensure that only authorized personnel can access sensitive resources such as namespaces, secrets, and deployments.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License
This project is licensed under the MIT License.
