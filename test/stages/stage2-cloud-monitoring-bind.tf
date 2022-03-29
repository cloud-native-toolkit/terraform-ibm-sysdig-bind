module "sysdig-bind" {
  source = "./module"

  region                   = var.region
  ibmcloud_api_key         = var.ibmcloud_api_key
  resource_group_name      = module.resource_group.name
  guid                     = module.cloud_monitoring.guid
  access_key               = module.cloud_monitoring.access_key
  cluster_name             = module.dev_cluster.name
  cluster_id               = module.dev_cluster.id
  private_endpoint         = "false"
}
