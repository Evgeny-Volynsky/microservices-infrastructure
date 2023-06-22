
# Deploying ArgoCD on a K3s Cluster using Helm

This guide will take you through the steps to install ArgoCD on a K3s cluster using Helm and the App of Apps pattern. We will also configure Traefik as the ingress controller.

Assumptions:

- A K3s cluster is already set up.

## Step 1: Install ArgoCD

We'll use Helm to install ArgoCD.

if helm is not installed:

`snap install helm`

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
   kubectl apply -f argo-helm.yaml

```

## Step 2: Expose ArgoCD with Traefik Ingress

We'll create a Traefik IngressRoute to expose the ArgoCD service.

1. make sure our ingress is reachable:
   we can find the ip and port Traefik is listening to like this

   ```bash
   traefik_uri=kubectl get svc/traefik -n kube-system -o=jsonpath='{.status.loadBalancer.ingress[0].ip}''{":"}''{.spec.ports[?(@.port==443)].nodePort}'
   ```

   we can expose Traefik like list 
   ```bash
   iptables -t nat -A PREROUTING -p tcp --dport 443 -d $PUBLIC_IP -j DNAT --to-destination $traefik_uri
   ```
3. Apply this configuration with kubectl:

   ```bash
   kubectl apply -f ingress.yaml
   ```

---

**Note**: 
You should adapt the given host to your own host in the ingress.yaml, argo.yaml and helm-argo.yaml. (This will be soon adapted)

These steps are a simplified version of the installation process. For a production-grade setup, you should consider configuring resource limits, readiness probes, and other Kubernetes best practices. Also, make sure to secure your ArgoCD instance by setting up authentication and authorization.