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

  mock_outputs = {
    secret_id = "null"
    role_id   = "null"
  }
}

inputs = {
  vault_secret_id = dependency.vault-config.outputs.secret_id
  vault_role_id   = dependency.vault-config.outputs.role_id
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
