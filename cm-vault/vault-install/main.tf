terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig_path)
  }
}

# deploy vault
resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  wait             = true
  version          = var.vault_version

  set {
    # This installs a single unsealed Vault server in the insecure dev mode with a memory storage backend.
    name  = "server.dev.enabled"
    value = "true"
  }
}

# Wait for Vault StatefulSet to become Ready before proceeding. Helm release
# seems to not be configurable in such a way as to wait for a StatefulSet to be
# ready https://github.com/helm/helm/pull/10920
resource "null_resource" "wait_for_vault" {
  provisioner "local-exec" {
   environment = {
    KUBECONFIG = pathexpand(var.kubeconfig_path)
   }
   command = "kubectl wait --for condition=Ready=true pod/vault-0 -n vault --timeout 300s"
  }
  depends_on = [
    helm_release.vault
  ]
}
