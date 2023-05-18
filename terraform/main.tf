resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "bootstrap_token_secret" {
  length  = 16
  upper   = false
  special = false
}




module "secgroup" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack/security-group"
}

locals {
  token = "${random_password.bootstrap_token_id.result}.${random_password.bootstrap_token_secret.result}"
  common_k3s_args = [
    "--kube-apiserver-arg", "enable-bootstrap-token-auth",
    "--disable", "traefik",
    "--node-label", "az=${var.availability_zone}",
  ]
}

data "k8sbootstrap_auth" "auth" {
  depends_on = [module.secgroup]

  server = module.server.k3s_external_url
  token  = local.token
}

module "server" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack"

  name               = "k3s-server"
  image_id           = openstack_images_image_v2.rancheros.image_id
  flavor_id          = openstack_compute_flavor_v2.server-flavor.flavor_id
  availability_zone  = var.availability_zone
  keypair_name       = openstack_compute_keypair_v2.k3s.name
  network_id         = openstack_networking_network_v2.kubernetes.id
  subnet_id          = openstack_networking_subnet_v2.kubernetes.id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = 1
  floating_ip_pool   = var.floating_ip_pool

  cluster_token          = random_password.cluster_token.result
  k3s_args                = concat(["server", "--cluster-init"], local.common_k3s_args)
  bootstrap_token_id     = random_password.bootstrap_token_id.result
  bootstrap_token_secret = random_password.bootstrap_token_secret.result
}

module "agents" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack"

  count = 2

  name               = "k3s-agent-${count.index + 1}"
  image_id           = openstack_images_image_v2.rancheros.image_id
  flavor_id          = openstack_compute_flavor_v2.agent-flavor.flavor_id
  availability_zone  = var.availability_zone
  keypair_name       = openstack_compute_keypair_v2.k3s.name
  network_id         = openstack_networking_network_v2.kubernetes.id
  subnet_id          = openstack_networking_subnet_v2.kubernetes.id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = 5

  k3s_join_existing = true
  k3s_url           = module.server.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args           = ["agent", "--node-label", "az=${var.availability_zone}"]
}

output "cluster_token" {
  value     = random_password.cluster_token.result
  sensitive = true
}

output "k3s_url" {
  value = module.server.k3s_url
}

output "k3s_external_url" {
  value = module.server.k3s_external_url
}

output "server_ip" {
  value = module.server.node_ip
}

output "server_external_ip" {
  value = module.server.node_external_ip
}

output "server_user_data" {
  value     = module.server.user_data
  sensitive = true
}

output "token" {
  value     = local.token
  sensitive = true
}

output "ca_crt" {
  value = data.k8sbootstrap_auth.auth.ca_crt
}

output "kubeconfig" {
  value     = data.k8sbootstrap_auth.auth.kubeconfig
  sensitive = true
}

provider "kubernetes" {
  host                   = module.server.k3s_url
  token                  = local.token
  cluster_ca_certificate = data.k8sbootstrap_auth.auth.ca_crt
}
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "iulia"
  auth_url    = "http://10.0.0.2:5000/v3"
  region      = "RegionOne"
}
