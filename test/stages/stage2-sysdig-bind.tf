module "sysdig-bind" {
  source = "./module"

  resource_group_name      = module.resource_group.name
  region                   = var.region
  name                     = module.dev_sysdig.name
  cluster_name             = module.dev_cluster.name
  cluster_id               = module.dev_cluster.id
  cluster_config_file_path = module.dev_cluster.config_file_path
  tools_namespace          = module.dev_capture_state.namespace
}
