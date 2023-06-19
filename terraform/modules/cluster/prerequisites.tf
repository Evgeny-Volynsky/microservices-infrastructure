resource "openstack_compute_keypair_v2" "k3s" {
  name = "k3s"
}


resource "openstack_networking_network_v2" "kubernetes" {
  name           = "kubernetes"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "kubernetes" {
  network_id = "${openstack_networking_network_v2.kubernetes.id}"
  cidr       = "192.168.199.0/24"
}


data "openstack_networking_network_v2" "external_net"{
  name=var.external_net_name

}

resource "openstack_networking_router_v2" "router" {
  name             = "router"
  admin_state_up   = "true"
  external_network_id = data.openstack_networking_network_v2.external_net.id
}
resource "openstack_networking_router_interface_v2" "router_internal_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.kubernetes.id
}