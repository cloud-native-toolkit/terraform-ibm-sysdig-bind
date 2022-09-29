module "cloud_monitoring" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-cloud-monitoring.git"

  resource_group_name      = module.resource_group.name
  region                   = var.region
  provision                = true
  name_prefix              = local.name_prefix
}
