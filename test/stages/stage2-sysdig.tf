module "dev_sysdig" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-sysdig.git"

  resource_group_name      = module.resource_group.name
  region                   = var.region
  provision                = false
  name_prefix              = var.name_prefix
}
