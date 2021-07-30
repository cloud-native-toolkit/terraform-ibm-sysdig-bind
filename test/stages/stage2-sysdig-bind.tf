module "sysdig-bind" {
  source = "./module"

  region                   = var.region
  ibmcloud_api_key         = var.ibmcloud_api_key
  resource_group_name      = module.resource_group.name
  guid                     = module.dev_sysdig.guid
  access_key               = module.dev_sysdig.access_key
  cluster_name             = module.dev_cluster.name
  cluster_id               = module.dev_cluster.id
  private_endpoint         = "false"
}
