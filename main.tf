
locals {
  tmp_dir     = "${path.cwd}/.tmp"
  role        = "Manager"
  bind        = var.cluster_name != ""
}

resource null_resource ibmcloud_login {
  provisioner "local-exec" {
    command = "${path.module}/scripts/ibmcloud-login.sh ${var.region} ${var.resource_group_name}"

    environment = {
      APIKEY = var.ibmcloud_api_key
    }
  }
}

resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Sysdig instance: ${var.guid}'"
  }
}

resource "null_resource" "setup-ob-plugin" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-ob-plugin.sh"
  }
}

resource "null_resource" "sysdig_bind" {
  count = local.bind ? 1 : 0
  depends_on = [null_resource.setup-ob-plugin, null_resource.ibmcloud_login]

  triggers = {
    cluster_id  = var.cluster_id
    instance_id = var.guid
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/bind-instance.sh ${self.triggers.cluster_id} ${self.triggers.instance_id} ${var.access_key} ${var.private_endpoint}"

    environment = {
      SYNC = var.sync
    }
  }

  provisioner "local-exec" {
    when    = destroy

    command = "${path.module}/scripts/unbind-instance.sh ${self.triggers.cluster_id} ${self.triggers.instance_id}"
  }
}
