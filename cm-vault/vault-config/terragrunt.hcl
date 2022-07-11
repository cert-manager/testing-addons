dependency "vault-install" {
  config_path = "../vault-install"

  skip_outputs = "true"
}

terraform {
  before_hook "before_hook" {
    commands     = ["apply", "plan", "destroy"]
    execute      = ["${get_parent_terragrunt_dir()}/_shared/start_vault_service.sh"]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan", "destroy"]
    execute      = ["${get_parent_terragrunt_dir()}/_shared/stop_vault_service.sh"]
    run_on_error = true
  }

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
