# Development and Automation of Reliable Cloud Infrastructure for Scalable Microservices Deployment
## Table of Contents
1. [The goals of the project](#the-goals-of-the-project)
2. [The key ideas of the project](#the-key-ideas-of-the-project)
3. [The stages of the project](#the-stages-of-the-project)
   - [Stage 1 in Detail: Setting Up Secure Kubernetes Cluster](#stage-1-in-detail-setting-up-secure-kubernetes-cluster)
4. [The structure of the project](#the-structure-of-the-project)

## The goals of the project
* Prototype the secure, reliable, and scalable infrastructure of the data hub at cloud
* Leverage AMD-SEV encryption in the development and implementation of the data hub's infrastructure
* Review the already developed microservice architecture from a security point of view.
* Prototype a framework on how to test the microservice architecture

## The key ideas of the project
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/28bd562f-ff4a-44cd-9010-57725e6bf54e)
* End-to-End Microservice Deployment
   - Utilize Kubernetes (K8s) for orchestrating and managing microservices.
   - Leverage OpenStack for comprehensive cloud infrastructure support.
   - Achieve seamless deployment and scaling of microservices.
* Access Control with ArgoCD
   - Implement simple Access Control Lists (ACLs) using ArgoCD.
   - Ensure secure access and permissions management for microservices.
   - Facilitate continuous deployment with controlled access
* Distributed Storage Backend with Ceph
   - Use Ceph as a distributed storage system to manage the state/data of microservices.
   - Ensure high availability and fault tolerance with Ceph's distributed architecture.
   - Benefit from Ceph's scalability to accommodate growing data needs of microservices


## The stages of the project
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/d76b89a1-9da1-413c-aa45-27f0065fb2ec)

* **Stage 1**: Setting Up a Secure Kubernetes Cluster. Involves setting up a secure Kubernetes cluster on top of OpenStack. This setup aims to use LRZ resources efficiently to provide fast microservice deployment, workload scalability, and efficient resource utilization.
* **Stage 2**: Secure State Management of Microservices. Focuses on secure state management of microservices. This is achieved by leveraging hardware-assisted trusted computing, such as AMD SEV, to provide a secure execution environment and state management on the untrusted storage medium.
* **Stage 3**: Testing Mechanism for Microservices
Involves developing a testing mechanism to improve the reliability of microservices. This is done by combining fuzz testing and crash faults injections to expose potential issues and assess the system's resilience.
* **Stage 4**: Security Review of GHGA Microservice Architecture
Thorough security review of the GHGA microservice architecture. This review aims to identify and address potential security vulnerabilities in the system.

### Stage 1 in Detail: Setting Up Secure Kubernetes Cluster
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/cace9552-3720-4939-aed7-edc87f85c1fc)
The sequence diagram illustrates the process of setting up a secure Kubernetes cluster as part of Stage 1: Setting Up Secure Kubernetes Cluster. The diagram showcases the components involved and the sequence of actions performed during the setup process.

1. **Ansible:** The process starts with Ansible, a configuration management and automation tool. Ansible is responsible for installing a multi-node OpenStack infrastructure.

2. **OpenStack:** OpenStack is the infrastructure-as-a-service (IaaS) platform used for cloud computing. In this context, OpenStack integrates with Ansible to create the multi-node infrastructure required for the Kubernetes cluster.

3. **Ceph Storage:** Ceph Storage is integrated as a separate compute node to provide persistent volumes for the Kubernetes cluster. It ensures the availability and reliability of storage resources for the microservices.

4. **Terraform:** Terraform is a provisioning tool used to automate the installation of the Kubernetes cluster. It integrates with OpenStack to deploy and manage the cluster infrastructure.

5. **Kubernetes Cluster:** The Kubernetes Cluster is the core component of the setup. It is responsible for managing and orchestrating the microservices. The cluster is installed using Terraform, ensuring a secure and scalable environment for the microservices.

6. **ArgoCD:** ArgoCD is a GitOps tool used for continuous integration and continuous deployment (CI/CD). It integrates with the Kubernetes Cluster to enable GitOps workflows, allowing for automated deployments and management of microservices.

7. **Microservices:** The diagram represents the automatic deployment of microservices on the Kubernetes Cluster. These microservices are the applications and services that will run within the cluster, providing the desired functionality.

## The structure of the project
1. [multinode-kolla-ceph-install-deploy](https://github.com/Evgeny-Volynsky/microservices-infrastructure/tree/main/multinode-kolla-ceph-install-deploy): This folder contains the installation kit for setting up an OpenStack cluster with a control node, compute nodes, and a Ceph node.
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/be307581-f22b-4baf-93d1-cdc7bd2099a2)
**Important Scripts:**
   - **init-communication.sh** - adds the control node’s ssh public key to all the other nodes in the cluster such that it can ssh into them and prepare them for the Kolla-Ansible installation and should be run from developer’s machine
   - **init-control.sh** - adds sets up the control node and then will execute the other scripts: init-ceph.sh and init-compute.sh on the respective nodes. After setting up all the nodes in the cluster, init-control.sh will finally use the kolla-control.sh script which will setup Openstack across all nodes 
2. [terraform](https://github.com/Evgeny-Volynsky/microservices-infrastructure/tree/main/terraform): This folder contains the Terraform and Terragrunt files for setting up an immutable k3s cluster on an OpenStack infrastructure.
3. [all-in-one-install-deploy-openstack](https://github.com/Evgeny-Volynsky/microservices-infrastructure/tree/main/all-in-one-install-deploy-openstack): This folder contains scripts for a single-node OpenStack installation for testing purposes.
4. [argocd](https://github.com/Evgeny-Volynsky/microservices-infrastructure/tree/main/argocd): This folder contains configuration files and scripts for the ArgoCD tool, which manages end-to-end microservice deployment. It includes features for access control with ArgoCD, and distributed storage backend with Ceph.
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/2063af53-e401-436b-9008-56329312f9bd)

Each folder has a `README.md` file which contains detailed instructions and other important information about what's in the folder. 
