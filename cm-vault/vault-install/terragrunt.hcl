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
}
