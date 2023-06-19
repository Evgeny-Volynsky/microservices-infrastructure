output "image_id" {
  value= openstack_images_image_v2.debian.id
}

output "server_flavor_id" {
  value=openstack_compute_flavor_v2.server_flavor.id
}

output "agent_flavor_id" {
  value=openstack_compute_flavor_v2.agent_flavor.id
}

output "external_net_name" {
  value=openstack_networking_network_v2.external_net.name
}