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
