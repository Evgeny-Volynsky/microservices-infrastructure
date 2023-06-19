variable "availability_zone" {
  default = "nova"
}

variable "server_flavor_id" {
  type = string
}

variable "agent_flavor_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "external_net_name" {
  type = string
}
