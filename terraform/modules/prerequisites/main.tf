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

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  region      = "RegionOne"
}
