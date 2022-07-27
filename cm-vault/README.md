# Deploy and Setup Cert-manager and Vault

## Goals

This Terragrunt workflow deploys and configures cert-manager, Hashicorp Vault and a cert-manager Vault `ClusterIssuer` to an existing Kubernetes cluster.

Vault will be deployed in the insecure dev mode with a [PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki) configured for issuing certs for `cert-manager.io` subdomains by default.

A `ClusterIssuer` named `vault-issuer` will be created that can issue certs from this PKI using Vault's dev root token.

A `Certificate` named `demo-app-vault-cert` in `cert-demo` namespace will be created that issued by `vault-issuer`.

> Note: The allowed DNS names are restricted to subdomains of `cert-manager.io` by default.

## Dependencies Graph

Terragrunt is used to ensure the correct order of dependency installation, i.e that cert-manager `ClusterIssuer` is not created before installing cert-manager. See dependency graph below:

![image](graph.svg)

### cm-install

To use [Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) to install Cert-Manager into Kubernetes, you need to set `kubeconfig_path` that default is `~/.kube/config`.

### vault-install

To use Helm Provider to install Vault into Kubernetes. By default, it is a single unsealed Vault server in the insecure dev mode with a memory storage backend.

### vault-config

To use Vault Provider to configure Vault. By default, it setup a [PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki) configured for issuing certs for `cert-manager.io` subdomains.

### cm-config

To use Kubernetes Provider to configure Cert-Manager. By default, it create a `ClusterIssuer` named `vault-issuer` that can issue certs from this PKI using Vault's dev root token and a `Certificate` named `demo-app-vault-cert` that issued by `vault-issuer`.


## Usage Steps

### 1. Execute `terragrunt run-all init` to init providers of all modules.

### 2. Configurate custom variable.

You can configurate custom variables in `common.tfvars`.

```
# Path to the kubeconfig file to use for connecting kubernetes cluster. Default is "~/.kube/config"
kubeconfig_path = "~/.kube/config"

# Cert-manger version to install. Default is "v1.8.2"
cm_version = "v1.8.2"

# Vault version to install. Default is "0.20.1" that is Vault Helm version corresponding to Vault version "1.10.3".
# You can check the mapping between the Vault Helm version and the Vault version by executing `helm search repo hashicorp/vault -l`
vault_version = "0.20.1"

# The root domain of the Vault PKI. Default is "cert-manager.io"
vault_pki_root_domain = "cert-manager.io"

# The authentication mechanism of Vault to be used by ClusterIssuer/Issuer. Default is "approle", the other is "token".
# You can learn about the Vault authentication mechanism at https://cert-manager.io/docs/configuration/vault/#authenticating
vault_authentication_mechanism = "approle"
......
```

### 3. Execute `terragrunt run-all apply` to deploy all modules.

### 4. Execute `terragrunt run-all destroy` to clean test environment.
