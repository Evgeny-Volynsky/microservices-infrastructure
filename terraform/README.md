## Installation

To run the provided scripts, you have to install the following packages:
- Terraform:
 ```bash
  sudo snap install terraform --classic
```
- Install Terragrunt from https://github.com/gruntwork-io/terragrunt/releases
- Kubectl:
```bash
  snap install kubectl --classic
```

## Deployment

Before running terragrunt, we need to expose 2 environment variables:


`export OS_AUTH_URL=`: should be in the pattern of `http://{CONTROL_NODE_IP}:5000/v3`

`export OS_PASSWORD=`: password set for admin user : `cat /etc/kolla/passwords.yml | grep "keystone_admin_password"`


To deploy a k3s cluster with Terraform on OpenStack we have to do the following steps:

```bash
  cd microservices-infrastructure/terraform/cluster/prerequisites
  terragrunt init
  terragrunt plan -out prerequisites
  terragrunt apply prerequisites
```

```bash
  cd microservices-infrastructure/terraform/cluster
  terragrunt init
  terragrunt plan -out cluster
  terragrunt apply cluster
```

To retrieve the kubeconfig run

```bash
  terragrunt output kubeconfig
```
add contents of output into file
```bash
  mkdir ~/.kube
  touch ~/.kube/config
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

<img width="581" alt="Screenshot 2023-05-31 at 11 55 21" src="https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/16737171/130b5517-f92d-481e-9770-31fad8369e47">
<br /> <br />
<img width="896" alt="Screenshot 2023-05-31 at 11 55 13" src="https://github.com/Evgeny-Volynsky/microservices-infrastructure/assets/16737171/1ec5169a-b22a-405b-bf35-840c2df61164">
<br/>

Now, we ssh tunnel into our cluster using the following command with the respective cluster_ip and service_port that we found out in the previous step:
```bash
  ssh -N  -L 8080:cluster_ip:service_port kolla@public_ip_openstack
```
As an example, in our case the exact command would be:
```bash
  ssh -N  -L 8080:10.0.2.150:30912 kolla@iulia.duckdns.org 
```



