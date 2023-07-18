# Development and Automation of Reliable Cloud Infrastructure for Scalable Microservices Deployment
## The goals of the project
* Prototype the secure, reliable, and scalable infrastructure of the data hub at cloud
* Leverage AMD-SEV encryption in the development and implementation of the data hub's infrastructure
* Review the already developed microservice architecture from a security point of view.
* Prototype a framework on how to test the microservice architecture

## The stages of the project
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/d76b89a1-9da1-413c-aa45-27f0065fb2ec)
* **Stage 1**: Setting Up a Secure Kubernetes Cluster![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/37aea9fa-0b29-4af6-b5a8-fa45af21ad88)
Involves setting up a secure Kubernetes cluster on top of OpenStack. This setup aims to use LRZ resources efficiently to provide fast microservice deployment, workload scalability, and efficient resource utilization.
* **Stage 2**: Secure State Management of Microservices ![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/b7fb573f-4010-45f7-be0d-2d101cd10617)

Focuses on secure state management of microservices. This is achieved by leveraging hardware-assisted trusted computing, such as AMD SEV, to provide a secure execution environment and state management on the untrusted storage medium.
* **Stage 3**: Testing Mechanism for Microservices
Involves developing a testing mechanism to improve the reliability of microservices. This is done by combining fuzz testing and crash faults injections to expose potential issues and assess the system's resilience.
* **Stage 4**: Security Review of GHGA Microservice Architecture
Thorough security review of the GHGA microservice architecture. This review aims to identify and address potential security vulnerabilities in the system.

## Stage 1: Setting Up Secure Kubernetes Cluster
![image](https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/10652693/cace9552-3720-4939-aed7-edc87f85c1fc)
The sequence diagram illustrates the process of setting up a secure Kubernetes cluster as part of Stage 1: Setting Up Secure Kubernetes Cluster. The diagram showcases the components involved and the sequence of actions performed during the setup process.

1. **Ansible:** The process starts with Ansible, a configuration management and automation tool. Ansible is responsible for installing a multi-node OpenStack infrastructure.

2. **OpenStack:** OpenStack is the infrastructure-as-a-service (IaaS) platform used for cloud computing. In this context, OpenStack integrates with Ansible to create the multi-node infrastructure required for the Kubernetes cluster.

3. **Ceph Storage:** Ceph Storage is integrated as a separate compute node to provide persistent volumes for the Kubernetes cluster. It ensures the availability and reliability of storage resources for the microservices.

4. **Terraform:** Terraform is a provisioning tool used to automate the installation of the Kubernetes cluster. It integrates with OpenStack to deploy and manage the cluster infrastructure.

5. **Kubernetes Cluster:** The Kubernetes Cluster is the core component of the setup. It is responsible for managing and orchestrating the microservices. The cluster is installed using Terraform, ensuring a secure and scalable environment for the microservices.

6. **ArgoCD:** ArgoCD is a GitOps tool used for continuous integration and continuous deployment (CI/CD). It integrates with the Kubernetes Cluster to enable GitOps workflows, allowing for automated deployments and management of microservices.

7. **Microservices:** The diagram represents the automatic deployment of microservices on the Kubernetes Cluster. These microservices are the applications and services that will run within the cluster, providing the desired functionality.
