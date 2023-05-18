resource "openstack_compute_keypair_v2" "k3s" {
  name = "k3s"
}
resource "openstack_images_image_v2" "rancheros" {
  name             = "RancherOS"
  image_source_url = "https://releases.rancher.com/os/latest/rancheros-openstack.img"
  container_format = "bare"
  disk_format      = "qcow2"
}

resource "openstack_networking_network_v2" "kubernetes" {
  name           = "kubernetes"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "kubernetes" {
  network_id = "${openstack_networking_network_v2.kubernetes.id}"
  cidr       = "192.168.199.0/24"
}

resource "openstack_compute_flavor_v2" "server-flavor" {
  name  = "server-flavor"
  ram   = "2048"
  vcpus = "1"
  disk  = "20"

  extra_specs = {
    "hw:cpu_policy"        = "CPU-POLICY",
    "hw:cpu_thread_policy" = "CPU-THREAD-POLICY"
  }
}

resource "openstack_compute_flavor_v2" "agent-flavor" {
  name  = "agent-flavor"
  ram   = "4096"
  vcpus = "1"
  disk  = "20"

  extra_specs = {
    "hw:cpu_policy"        = "CPU-POLICY",
    "hw:cpu_thread_policy" = "CPU-THREAD-POLICY"
  }
}