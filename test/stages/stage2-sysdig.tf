module "dev_sysdig" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-sysdig.git"

  resource_group_name      = module.resource_group.name
  region                   = var.region
  provision                = true
  name_prefix              = var.name_prefix
  ibmcloud_api_key         = var.ibmcloud_api_key
}
