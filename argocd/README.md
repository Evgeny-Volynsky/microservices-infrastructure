
# Deploying ArgoCD on a K3s Cluster using Helm

This guide will take you through the steps to install ArgoCD on a K3s cluster using Helm. We will also configure Traefik as the ingress controller.

Assumptions:

- A K3s cluster is already set up.
## Step 1: supply host name and TLS email address
Run the `argo.sh` script in this directory to create the files referenced below.
It will ask for the host name to be used and then prepare the files to use the supplied hostname
It will also ask for an email to use for Let's Encrypt HTTP01 Acme Certificate Requests.


## Step 2: Install ArgoCD

We'll use Helm to install ArgoCD.

if helm is not installed:

`snap install helm --classic`

1. Add the ArgoCD Helm chart repository:
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm repo update
   ```
2. Install ArgoCD in the `argocd` namespace. If the namespace doesn't exist, we will create it:

   ```bash
   kubectl create namespace argocd
   helm install --create-namespace --namespace argocd -f argo.yaml argo argo/argo-cd
   ```
Alternatively, you can simply run :
```bash
   kubectl apply -f helm-argo.yaml

```

## Step 3: Expose ArgoCD with Traefik Ingress

We'll create a Traefik IngressRoute to expose the ArgoCD service.
1. Enable Let's Encrypt with Traefik by:
```bash
   kubectl apply -f traefik.yaml

```

2. Make sure our ingress is reachable:
   we can find the ip and port Traefik is listening to like this

   ```bash
   traefik_uri=$(kubectl get svc/traefik -n kube-system -o=jsonpath='{.status.loadBalancer.ingress[0].ip}''{":"}''{.spec.ports[?(@.port==443)].nodePort}')
   ```

   we can expose Traefik like list 
   ```bash
   export PUBLIC_IP=... (public ip of the controller)
   iptables -t nat -A PREROUTING -p tcp --dport 443 -d $PUBLIC_IP -j DNAT --to-destination $traefik_uri
   ```
3. Apply this configuration with kubectl:

   ```bash
   kubectl apply -f ingress.yaml
   ```
4. To access the argocd dashboard as an admin, you should run the following command that retrieves the login details as yaml. Then you should decode it from base64:
   ```bash
  kubectl get secret argocd-initial-admin-secret -o yaml -n argocd
   ```

## ArgoCD Roles

In the Base Configuration we use github as our oauth provider with a github organization
See https://dexidp.io/docs/connectors/ for other connectors compatible.

The RBAC configuration is done in the policy.csv file in an argocd (configmap)[https://github.com/Evgeny-Volynsky/microservices-infrastructure/blob/main/argocd/helm-argo.yaml.tmpl#L33].

to add new groups with github define policies for the group like this 

 ```csv
          p, role:developer, applications, get, */*, allow
          p, role:developer, applications, create, */*, allow
          p, role:developer, applications, update, */*, allow
          p, role:developer, logs, get, */*, allow
          p, role:developer, exec, create, */*, allow
          p, role:devops, applications, get, */*, allow
          p, role:devops, applications, update, */*, allow
          p, role:devops, applications, sync, */*, allow
          p, role:devops, applications, override, */*, allow
          p, role:devops, logs, get, */*, allow,
          p, role:devops, exec, create, */*, allow

     
   ```

  and then apply them to the mapped organization team:
  ```csv
            g, organizationName:Developers, role:developer
            g, organizationName:DevOps, role:devops
  ```
  




---

**Note**: 

You should adapt the given host to your own host in the ingress.yaml, argo.yaml and helm-argo.yaml. (This will be soon adapted)

These steps are a simplified version of the installation process. For a production-grade setup, you should consider configuring resource limits, readiness probes, and other Kubernetes best practices. Also, make sure to secure your ArgoCD instance by setting up authentication and authorization.
