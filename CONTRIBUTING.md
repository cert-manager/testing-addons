# Contributing

## Adding A New Workflow

For adding a new addon testing workflow, we need to divide the installation steps reasonably, and then design the corresponding `Terraform module` for each step.

In general, the installation and configuration of addons are divided into two `Terraform modules`, so that it is easy to rely on other modules to complete the configuration.

Create a `terragrunt.hcl` file under each `Terraform module` to configure `Terragrunt`.

### Workflow Directory Structure

Take the `Vault testing workflow` as an example.

```bash
./cm-vault
├── cm-config # Terraform module
│   ├── main.tf
│   ├── terragrunt.hcl # Terragrunt configuration file
│   └── variables.tf
├── cm-install
│   ├── main.tf
│   ├── terragrunt.hcl
│   └── variables.tf
├── common.tfvars
├── graph.svg
├── README.md
├── vault-config
│   ├── main.tf
│   ├── _shared # Custom configuration file
│   │   ├── start_vault_service.sh
│   │   └── stop_vault_service.sh
│   ├── terragrunt.hcl
│   └── variables.tf
└── vault-install
    ├── main.tf
    ├── terragrunt.hcl
    └── variables.tf
```

### Inter-Module Dependencies

First install `Cert-manager` and `Vault` at the same time, modules without any dependencies can be executed in parallel, thus saving deployment time.

Since creating `vault-issuer` requires creating and configuring `Vault PKI` firstly, we need to configure `Vault` first, and then configure `Cert-manager`.

The Dependency relationship is shown below.

![image](cm-vault/graph.svg)

Configure dependencies in `cm-vault/cm-config/terragrunt.hcl` so that `vault-issuer` cannot be created until `Cert-manager` is successfully installed and `Vault` is configured.

```
# ./cm-vault
# ├── cm-config
# │   ├── terragrunt.hcl

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
```

### Custom Variable

By configuring the following in `cm-vault/cm-config/terragrunt.hcl`, we can set the variables of each module globally in the `cm-vault/common.tfvars` file.

```
# ./cm-vault
# ├── cm-config
# │   ├── terragrunt.hcl

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
```

The commonly used variables that can be customized by users are set here, which can facilitate the unified management of the workflow.

```
# ./cm-vault
# ├── common.tfvars

# Path to the kubeconfig file to use for connecting kubernetes cluster. Default is "~/.kube/config"
kubeconfig_path = "~/.kube/config"

# Cert-manger version to install. Default is "v1.10.0"
cm_version = "v1.10.0"
......
```

### Advance Configuration

More advance configurations, you can refer to offical documentations of [Terraform](https://www.terraform.io/docs) and [Terragrunt](https://terragrunt.gruntwork.io/docs/).
