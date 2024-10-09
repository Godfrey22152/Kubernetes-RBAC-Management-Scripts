# Kubernetes Service Account RBAC Setup

## Overview
This project demonstrates how to create Role-Based Access Control (RBAC) in Kubernetes using Service Accounts. We will explore how to assign roles to different users with different levels of permissions by generating custom service accounts and corresponding kubeconfig files. These accounts allow access to the Kubernetes cluster based on predefined roles.

### RBAC (Role-Based Access Control) in Kubernetes
RBAC in Kubernetes allows administrators to define who (users, groups, service accounts) can perform specific actions on resources in the cluster. RBAC is a crucial aspect of securing your Kubernetes cluster, as it ensures proper access control and enforces least privilege principles.

### Service Accounts
A **Service Account** is a special account type in Kubernetes, used by applications running in pods to authenticate with the cluster. It allows a set of permissions (defined by roles and role bindings) to be applied without relying on user credentials. 

Using **Service Accounts** for RBAC management is essential when you need to automate user creation and control user access programmatically.

### Methods of Creating Users for RBAC in Kubernetes

1. **Using Service Accounts (Recommended)**:
   - Service accounts are native to Kubernetes and are primarily used to provide access to resources for applications running inside the cluster. Each pod can be associated with a service account, which defines what the pod can or cannot access.
   - They are the most commonly recommended method for assigning roles because they are easy to manage within the cluster and integrate seamlessly with Kubernetes' RBAC model.
   
   **Advantages**:
   - Lightweight and built-in.
   - Directly integrated with Kubernetes.
   - Secure by default with limited permissions (least privilege principle).
   - Useful for assigning permissions to workloads (i.e., Pods).

2. **Kubernetes Users**:
   - Kubernetes does not have a native concept of "users" like service accounts. Users are typically managed **outside of the cluster**, either via:
     - **Certificates**: Kubernetes authenticates users via client certificates.
     - **Identity Providers**: These could include LDAP, OAuth2, or other federated identity systems using Kubernetes plugins like OpenID Connect.
     
   **Challenges**:
   - The process of setting up certificates or external identity providers can be cumbersome and inflexible compared to service accounts.
   - Kubernetes doesn't store user identities or credentials directly within the cluster, which means more complex external management is required.
   - Typically used for cluster administrators or human access (rather than workload access).
   
   **Advantages**:
   - Can be integrated with organizational user management systems.
   - Provides flexibility in integrating with external identity systems like Google Cloud Identity, AWS IAM, or other authentication systems.


## Project Structure
This project includes several files that automate the creation and deletion of RBAC resources in Kubernetes. Each service account gets a role, and a kubeconfig file is generated for the user.

### Files in the Project:
1. **`sa_rbac_config.yaml`**:
   - Defines the service accounts (users), roles, and permissions.
   - Structure:
     - `name`: The name of the user.
     - `role`: The role assigned to the user.
     - `permissions`: Permissions tied to the role, such as actions allowed on Kubernetes resources.

   **Example**:
   ```yaml
   users:
     - name: "admin-user"
       role: "admin-role"
       permissions:
         - apiGroups: ["*"]
           resources: ["*"]
           verbs: ["*"]

2. **`sa_create_K8s_rbac.sh`**:
   - Automates the creation of service accounts, tokens, kubeconfig files, and RBAC policies.
   - **Main Steps**:
     1. Creates a service account for each user defined in `sa_rbac_config.yaml`.
     2. Generates an authentication token for each service account.
     3. Creates a kubeconfig file for each user under the directory `$HOME/.kube/kubeconfigs`.
     4. Assigns roles and permissions using ClusterRoles and ClusterRoleBindings.

     **Example usage**:

       **Clone this repository**:
       ```bash
       git clone https://github.com/Godfrey22152/Kubernetes-RBAC-Management-Scripts.git
       cd Kubernetes-RBAC-Management-Scripts/K8s_ServiceAccount_RBAC_Scripts
       ```

       ```bash
        # Make script executable
       sudo chmod +x sa_create_K8s_rbac.sh

       # Run script 
       ./sa_create_K8s_rbac.sh
       ```
        
3. **`delete_sa_resource_K8s_rbac.sh`**:
   - Deletes the created service accounts, roles, role bindings, and kubeconfig files.
   - **`Main Steps`**:
     1. Deletes service accounts based on sa_rbac_config.yaml.
     2. Removes kubeconfig files for each service account.
     3. Deletes ClusterRoles and ClusterRoleBindings associated with each user.

     **`Example usage`**:

     ```bash
     # Make the file executable
     sudo chmod +x delete_sa_resource_K8s_rbac.sh

     # Run the script
     ./delete_sa_resource_K8s_rbac.sh
     ```

## Project Setup and Execution

### Prerequisites
 - A running Kubernetes cluster.
 - Access to the `kubectl` CLI tool.
 - The YAML processor `yq` installed on your system.

### Setup Steps
 1. **Clone the repository**:

    ```bash
    git clone https://github.com/Godfrey22152/Kubernetes-RBAC-Management-Scripts.git
    cd Kubernetes-RBAC-Management-Scripts/K8s_ServiceAccount_RBAC_Scripts
    ``` 

 2. **Ensure permissions**: Make sure you have permissions to create service accounts and RBAC resources on your cluster.

 3. **Modify `sa_rbac_config.yaml`**: Edit the `sa_rbac_config.yaml` file to define your service accounts, roles, and permissions as needed.

 4. **Run the `sa_create_K8s_rbac.sh` script**: This script will create all the necessary Kubernetes service accounts, tokens, kubeconfig files, and RBAC roles.

     ```bash
     # Make script executable
     sudo chmod +x sa_create_K8s_rbac.sh
     # Run script 
     ./sa_create_K8s_rbac.sh
     ```

### Verify Created Resources 
    After the script completes, verify the service accounts and roles have been created successfully.

 - **List service accounts**:
    ```bash
     kubectl get serviceaccounts -n default
    ```
 - **Check ClusterRoleBindings**:
    ```bash
     kubectl get clusterrolebindings
    ```
 - **Verify Kubeconfig files**:
    ```bash
     ls -lrt $HOME/.kube/kubeconfigs
    ```   

### Connecting to the Cluster
    Each user now has a corresponding kubeconfig file stored in `$HOME/.kube/kubeconfigs`. To use these configurations:

 - **Specify the kubeconfig file for a particular user**:
    ```bash
     export KUBECONFIG=$HOME/.kube/kubeconfigs/<user>.kubeconfig
     
     # For Instance:
     export KUBECONFIG=$HOME/.kube/kubeconfigs/admin-user.kubeconfig

     # verify access
     kubectl get nodes
     kubectl get pods
    ```
 - **Distribute kubeconfig Files to Users**

    To enable users to access the Kubernetes cluster from their own machines distribute the kubeconfig files securely to users. Once users have received their kubeconfig file, instruct them to follow these steps:

     - Ensure `kubectl` are installed on their machine.
     - Set the `KUBECONFIG`enironmental variable to point to the path of their `kubeconfig` file:

     ```bash
     export KUBECONFIG=/path/to/downloaded/username-kubeconfig.yaml 

     # For Instance:
     export KUBECONFIG=$HOME/Downloads/admin-user-kubeconfig.yaml
    ```
      
 - **Verify access**:
    The user can now use `kubectl` with the permissions of the `admin-user` Service Account.

    ```bash
     kubectl get nodes
     kubectl get pods
     kubectl get deployments
    ```
### Resource Deletion and Cleanup
To remove all the service accounts, roles, bindings, and kubeconfig files created by the script, run the `delete_sa_resource_K8s_rbac.sh` script:

    ```bash
    # Ensure it is executable
    sudo chmod +x delete_sa_resource_K8s_rbac.sh

     # Run the script
    ./delete_sa_resource_K8s_rbac.sh
    ```

 - **Verify deletion**:
    Ensure all service accounts are deleted:
    ```bash
    kubectl get serviceaccounts -n default
    ```

 - **Check that all ClusterRoleBindings are removed**:
    ```bash
    kubectl get clusterrolebindings
    ```
 - **Verify the kubeconfig directory has been removed**:
    ```bash
    ls $HOME/.kube/kubeconfigs
    ```

---
## Conclusion

This project provides a simple yet effective way to manage Kubernetes user accounts and permissions using service accounts. It automates the process of creating and deleting these resources, making it easier to enforce access controls in your cluster. By leveraging service accounts for RBAC, you can achieve fine-grained control over who has access to your Kubernetes resources.

---
## References

For more detailed information about Service Accounts in Kubernetes, please refer to the official Kubernetes documentation: 
[Service Accounts - Kubernetes](https://kubernetes.io/docs/concepts/security/service-accounts/)

[Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)