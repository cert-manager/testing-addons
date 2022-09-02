dependency "ingress-controller-install" {
  config_path = "../ingress-controller-install"

  skip_outputs = "true"
}

dependency "cm-config" {
  config_path = "../cm-config"

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

  extra_arguments "compact-warnings" {
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
