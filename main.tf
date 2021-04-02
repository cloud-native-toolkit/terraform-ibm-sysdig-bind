
locals {
  tmp_dir     = "${path.cwd}/.tmp"
  name        = var.name
  role        = "Manager"
  bind        = var.name != "" && var.cluster_name != ""
  access_key  = local.bind ? ibm_resource_key.sysdig_instance_key[0].credentials["Sysdig Access Key"] : ""
  cluster_type_file = "${local.tmp_dir}/cluster_type.out"
  cluster_type      = data.local_file.cluster_type.content
}

resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Sysdig instance: ${var.name}'"
  }
}

data "ibm_resource_group" "tools_resource_group" {
  depends_on = [null_resource.print_names]

  name = var.resource_group_name
}

data "ibm_resource_instance" "sysdig_instance" {
  depends_on = [null_resource.print_names]
  count             = local.bind ? 1 : 0

  name              = local.name
  service           = "sysdig-monitor"
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  location          = var.region
}

resource "ibm_resource_key" "sysdig_instance_key" {
  count = local.bind ? 1 : 0

  name                 = "${local.name}-key"
  resource_instance_id = data.ibm_resource_instance.sysdig_instance[0].id
  role                 = local.role

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

resource "null_resource" "setup-ob-plugin" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-ob-plugin.sh"
  }
}

resource "null_resource" "sysdig_bind" {
  count = local.bind ? 1 : 0
  depends_on = [null_resource.setup-ob-plugin]

  triggers = {
    cluster_id  = var.cluster_id
    instance_id = data.ibm_resource_instance.sysdig_instance[0].guid
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/bind-instance.sh ${self.triggers.cluster_id} ${self.triggers.instance_id} ${local.access_key} ${var.private_endpoint}"

    environment = {
      SYNC = var.sync
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/unbind-instance.sh ${self.triggers.cluster_id} ${self.triggers.instance_id}"
  }
}

resource null_resource create_tmp_dir {
  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }
}

resource null_resource cluster_type {
  depends_on = [null_resource.create_tmp_dir]

  provisioner "local-exec" {
    command = "kubectl api-resources -o name | grep consolelink && echo -n 'ocp4' > ${local.cluster_type_file}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

data local_file cluster_type {
  depends_on = [null_resource.cluster_type]

  filename = local.cluster_type_file
}

resource "null_resource" "delete-consolelink" {
  count = local.bind ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl api-resources -o name | grep consolelink && kubectl delete consolelink -l grouping=garage-cloud-native-toolkit -l app=sysdig || exit 0"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "helm_release" "sysdig" {
  count      = local.bind ? 1 : 0
  depends_on = [null_resource.sysdig_bind, null_resource.delete-consolelink]

  name              = "sysdig"
  chart             = "tool-config"
  namespace         = var.tools_namespace
  repository        = "https://ibm-garage-cloud.github.io/toolkit-charts/"
  timeout           = 1200
  force_update      = true
  replace           = true

  disable_openapi_validation = true

  set {
    name  = "displayName"
    value = "Sysdig"
  }

  set {
    name  = "url"
    value = "https://cloud.ibm.com/observe/monitoring"
  }

  set {
    name  = "applicationMenu"
    value = true
  }

  set {
    name  = "global.clusterType"
    value = local.cluster_type
  }
}
