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
    config_path = var.kubeconfig_path
  }
}

# deploy vault
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace        = "vault"
  create_namespace = true
  version          = "0.20.1" # The version of Vault is 1.10.3

  set {
    # This installs a single unsealed Vault server in the insecure dev mode with a memory storage backend.
    name  = "server.dev.enabled"
    value = "true"
  }

  set {
    name = "server.service.type"
    value = "NodePort"
  }

  set {
    name = "server.service.nodePort"
    value = "30200"
  }
}

# wait for port-forwarding successfully
resource "time_sleep" "wait_30_seconds" {
  depends_on = [helm_release.vault]

  create_duration = "30s"
}
