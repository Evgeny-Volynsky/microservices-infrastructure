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



resource "openstack_networking_network_v2" "external_net" {
  name           = "external_network"
  admin_state_up = "true"
  external       = "true"
  segments {
    physical_network = "physnet1"
    network_type     = "flat"
  }
}

resource "openstack_networking_subnet_v2" "external_subnet" {
  name       = "external_subnet"
  network_id = "${openstack_networking_network_v2.external_net.id}"
  cidr       = "10.0.2.0/24"
  ip_version = 4
  gateway_ip = "10.0.2.1"
  allocation_pool {
    start = "10.0.2.150"
    end   = "10.0.2.199"
  }
  enable_dhcp = false
}

resource "openstack_networking_router_v2" "router" {
  name             = "router"
  admin_state_up   = "true"
  external_network_id = openstack_networking_network_v2.external_net.id
}
resource "openstack_networking_router_interface_v2" "router_internal_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.kubernetes.id
}