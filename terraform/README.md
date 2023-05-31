## Installation

To run the provided scripts, you have to install the following packages:
- Terraform:
 ```bash
  sudo snap install terraform --classic
```
- Terragrunt: 
```bash
  sudo snap install terragrunt
```
- Kubectl:
```bash
  snap install kubectl --classic
```

## Deployment

To deploy a k3s cluster with Terraform on OpenStack we have to do the following steps:

```bash
  cd microservices-infrastructure/terraform/cluster/prerequisites
  terraform init
  terragrunt plan -out prerequisites
  terragrunt apply prerequisites
```

```bash
  cd microservices-infrastructure/terraform/cluster
  terraform init
  terragrunt plan -out cluster
  terragrunt apply cluster
```

To deploy a Kubernetes test app (located in microservices-infrastructure/test-deployment.yaml) 

```bash
  kubectl apply -f test-deployment.yaml 
  kubectl get deployment
  kubectl get pods
  kubectl get service kube-test-container
```

As the Kubernetes cluster is using port forwarding to access the application running on the cluster, you will need the IP of the control plane 
```bash
  kubectl cluster-info
```
and the port used by the service:
```bash
  kubectl get service kube-test-container
```

Here you can see some examples and how to understand the kubectl output

<img width="896" alt="control-plane-ip" src="https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/16737171/42b77ad6-fcbc-43b3-abba-b243ae169a32">

<br />

<img width="581" alt="service-port" src="https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/16737171/05b77f12-5ac6-409f-b2da-a7db3a96f497">

<br/>

Now, we ssh tunnel into our cluster using the following command with the respective cluster_ip and service_port that we found out in the previous step:
```bash
  ssh -N  -L 8080:cluster_ip:service_port kolla@public_ip_openstack
```
As an example, in our case the exact command would be:
```bash
  ssh -N  -L 8080:10.0.2.150:30912 kolla@iulia.duckdns.org 
```



