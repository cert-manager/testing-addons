dependency "vault-install" {
  config_path = "../vault-install"

  skip_outputs = "true"
}

dependency "cm-install" {
  config_path = "../cm-install"

  skip_outputs = "true"
}


dependency "vault-config" {
  config_path = "../vault-config"

  skip_outputs = "true"
}

terraform {
  extra_arguments "common_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]

    arguments = [
      "-var-file=${get_parent_terragrunt_dir()}/../common.tfvars"
    ]
  }

  extra_arguments "silence-warnings" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]

    arguments = [
      "-compact-warnings"
    ]
  }
}
