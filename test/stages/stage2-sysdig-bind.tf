module "sysdig-bind" {
  source = "./module"

  region                   = var.region
  guid                     = module.dev_sysdig.guid
  access_key               = module.dev_sysdig.access_key
  cluster_name             = module.dev_cluster.name
  cluster_id               = module.dev_cluster.id
  cluster_config_file_path = module.dev_cluster.config_file_path
  tools_namespace          = module.dev_capture_state.namespace
  private_endpoint         = "false"
}
