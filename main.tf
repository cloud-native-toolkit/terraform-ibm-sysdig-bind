
locals {
  tmp_dir     = "${path.cwd}/.tmp"
  role        = "Manager"
  bind        = var.cluster_name != ""
}

module setup_clis {
  source = "cloud-native-toolkit/clis/util"

  clis = ["ibmcloud-ob"]
}

resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Sysdig instance: ${var.guid}'"
  }
}

resource "null_resource" "sysdig_bind" {
  count = local.bind ? 1 : 0

  triggers = {
    bin_dir = module.setup_clis.bin_dir
    cluster_id  = var.cluster_id
    instance_id = var.guid
    ibmcloud_api_key = var.ibmcloud_api_key
    region = var.region
    resource_group_name = var.resource_group_name
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/bind-instance.sh ${self.triggers.cluster_id} ${self.triggers.instance_id} ${var.access_key} ${var.private_endpoint}"

    environment = {
      IBMCLOUD_API_KEY = nonsensitive(self.triggers.ibmcloud_api_key)
      REGION = self.triggers.region
      RESOURCE_GROUP = self.triggers.resource_group_name
      BIN_DIR = self.triggers.bin_dir
      SYNC = var.sync
    }
  }

  provisioner "local-exec" {
    when    = destroy

    command = "${path.module}/scripts/unbind-instance.sh ${self.triggers.cluster_id} ${self.triggers.instance_id}"

    environment = {
      IBMCLOUD_API_KEY = nonsensitive(self.triggers.ibmcloud_api_key)
      REGION = self.triggers.region
      RESOURCE_GROUP = self.triggers.resource_group_name
      BIN_DIR = self.triggers.bin_dir
    }
  }
}
