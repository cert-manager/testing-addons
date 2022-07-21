<p align="center">
  <img src="https://raw.githubusercontent.com/cert-manager/cert-manager/d53c0b9270f8cd90d908460d69502694e1838f5f/logo/logo-small.png" height="256" width="256" alt="cert-manager project logo" />
</p>

# Testing Addons

This repository contains testing addons for the cert-manager project.

It is to save time when testing cert-manager working with external dependencies.

Mainly refer this [proposal](https://docs.google.com/document/d/14oJux-d-91Do3DLi5eRG-wUEE4R3Hh7D4u0Yfje3auw/edit#heading=h.9chr39ggpwbe).

## Precondition

### [Install Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

Kubectl is used to perform actions that are not supported by native Terraform resources

### [Install Helm](https://helm.sh/docs/intro/install/)

Helm is the best way to find, share, and use software built for Kubernetes.

### [Install Terraform](https://www.terraform.io/downloads)

Terraform is an IT infrastructure automation orchestration tool.

### [Install Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state.

### Configure Terraform Plugin Cache.

The configuration directory of each dependence can share the cache to improve the execution speed.

```
$ mkdir -p $HOME/.terraform.d/plugin-cache
$ export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache" 
```

## Usage Steps

Take Vault as an example.

### 1. Go to the installation directory of specific dependency.

```
cd cm-vault
```

### 2. Execute `terragrunt run-all init`
```
$ terragrunt run-all init
INFO[0000] The stack at /root/lonelyCZ/testing-addons/cm-vault will be processed in the following order for command init:
Group 1
- Module /root/lonelyCZ/testing-addons/cm-vault/cm-install
- Module /root/lonelyCZ/testing-addons/cm-vault/vault-install

Group 2
- Module /root/lonelyCZ/testing-addons/cm-vault/vault-config

Group 3
- Module /root/lonelyCZ/testing-addons/cm-vault/cm-config


Initializing the backend...
```

### 3. Execute `terragrunt run-all apply`

```
$ terragrunt run-all apply
INFO[0000] The stack at /root/lonelyCZ/testing-addons/cm-vault will be processed in the following order for command apply:
Group 1
- Module /root/lonelyCZ/testing-addons/cm-vault/cm-install
- Module /root/lonelyCZ/testing-addons/cm-vault/vault-install

Group 2
- Module /root/lonelyCZ/testing-addons/cm-vault/vault-config

Group 3
- Module /root/lonelyCZ/testing-addons/cm-vault/cm-config

Are you sure you want to run 'terragrunt apply' in each folder of the stack described above? (y/n) y
```

### 4. Destroy Test Environment.

```
$ terragrunt run-all destroy
INFO[0000] The stack at /root/lonelyCZ/testing-addons/cm-vault will be processed in the following order for command destroy:
Group 1
- Module /root/lonelyCZ/testing-addons/cm-vault/cm-config

Group 2
- Module /root/lonelyCZ/testing-addons/cm-vault/cm-install
- Module /root/lonelyCZ/testing-addons/cm-vault/vault-config

Group 3
- Module /root/lonelyCZ/testing-addons/cm-vault/vault-install

WARNING: Are you sure you want to run `terragrunt destroy` in each folder of the stack described above? There is no undo! (y/n) y
```
