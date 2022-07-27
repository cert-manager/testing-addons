terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

// vault-token is used to connect vault
resource "kubernetes_secret_v1" "vault-token" {
  count = var.vault_authentication_mechanism == "token" ? 1 : 0

  metadata {
    name      = "vault-token"
    namespace = "cert-manager"
  }
  data = {
    token = "root"
  }
  type = "opaque"
}

resource "kubernetes_secret_v1" "vault-approle" {
  count = var.vault_authentication_mechanism == "approle" ? 1 : 0

  metadata {
    name      = "cert-manager-vault-approle"
    namespace = "cert-manager"
  }
  data = {
    secretId = var.vault_secret_id
  }
  type = "opaque"
}

resource "kubernetes_manifest" "vault-issuer-auth-token" {
  count = var.vault_authentication_mechanism == "token" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "vault-issuer"
    }
    "spec" = {
      "vault" = {
        "auth" = {
          "tokenSecretRef" = {
            "key"  = "token"
            "name" = "${kubernetes_secret_v1.vault-token[0].metadata[0].name}"
          }
        }
        "path"   = "pki/sign/cert-manager-io"
        "server" = "http://vault.vault.svc:8200"
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "1m"
    update = "1m"
    delete = "30s"
  }
}

resource "kubernetes_manifest" "vault-issuer-auth-approle" {
  count = var.vault_authentication_mechanism == "approle" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "vault-issuer"
    }
    "spec" = {
      "vault" = {
        "auth" = {
          "appRole" = {
            "path"   = "approle"
            "roleId" = var.vault_role_id
            "secretRef" = {
              "key"  = "secretId"
              "name" = "${kubernetes_secret_v1.vault-approle[0].metadata[0].name}"
            }
          }
        }
        "path"   = "pki/sign/cert-manager-io"
        "server" = "http://vault.vault.svc:8200"
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "1m"
    update = "1m"
    delete = "30s"
  }
}

resource "kubernetes_namespace_v1" "cert-demo" {
  metadata {
    name = "cert-demo"
  }
}

resource "kubernetes_manifest" "demo-app-vault-cert" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    metadata = {
      "name"      = "demo-app-vault-cert"
      "namespace" = "${kubernetes_namespace_v1.cert-demo.metadata[0].name}"
    }
    "spec" = {
      "commonName" = "demo-app.${var.vault_pki_root_domain}"
      "secretName" = "demo-app-tls"
      "dnsNames"   = ["demo-app.${var.vault_pki_root_domain}"]
      "issuerRef" = {
        "name" = var.vault_authentication_mechanism == "approle" ? kubernetes_manifest.vault-issuer-auth-approle[0].manifest.metadata.name : kubernetes_manifest.vault-issuer-auth-token[0].manifest.metadata.name
        "kind" = "ClusterIssuer"
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "1m"
    update = "1m"
    delete = "30s"
  }
}
