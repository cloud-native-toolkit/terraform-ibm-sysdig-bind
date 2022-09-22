terraform {
  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
    }
  }
  required_version = ">= 0.13"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  bin_dir = "${path.cwd}/test_bin_dir"
  clis = ["kubectl", "oc"]
}

resource local_file bin_dir {
  filename = "${path.cwd}/.bin_dir"

  content = module.setup_clis.bin_dir
}

resource random_string suffix {
  length = 16

  upper = false
  special = false
}

locals {
  name_prefix = "ee-${random_string.suffix.result}"
  resource_group_name = "ee-${random_string.suffix.result}"
  common_tags = ["lognda-bind",random_string.suffix.result]
}
