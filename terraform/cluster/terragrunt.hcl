terraform {
  source = "${get_path_to_repo_root()}//terraform/modules/cluster/"
}

dependency "prerequisites" {
  config_path = "${get_terragrunt_dir()}/prerequisites"
}

inputs =  {
  image_id = dependency.prerequisites.outputs.image_id
  server_flavor_id = dependency.prerequisites.outputs.server_flavor_id
  agent_flavor_id = dependency.prerequisites.outputs.agent_flavor_id
}