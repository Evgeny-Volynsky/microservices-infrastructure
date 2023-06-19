resource "openstack_compute_flavor_v2" "server_flavor" {
  name  = "server-flavor"
  ram   = "4096"
  vcpus = "2"
  disk  = "20"

  extra_specs = {
    "hw:cpu_policy"        = "shared",
  }
}

resource "openstack_compute_flavor_v2" "agent_flavor" {
  name  = "agent-flavor"
  ram   = "4096"
  vcpus = "2"
  disk  = "20"

  extra_specs = {
    "hw:cpu_policy"        = "shared",
  }
}

resource "openstack_images_image_v2" "debian" {
  name             = "Debian"
  image_source_url = "https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2"
  container_format = "bare"
  disk_format      = "qcow2"
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
  network_id = openstack_networking_network_v2.external_net.id
  cidr       = "10.0.2.0/24"
  ip_version = 4
  gateway_ip = "10.0.2.1"
  allocation_pool {
    start = "10.0.2.150"
    end   = "10.0.2.199"
  }
  enable_dhcp = false
}


provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  region      = "RegionOne"
}
