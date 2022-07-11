terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11.0"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

// vault-token is used to connect vault
resource "kubernetes_secret_v1" "vault-token" {
  metadata {
    name      = "vault-token"
    namespace = "cert-manager"
  }
  data = {
    token = "root"
  }
  type = "opaque"
}

resource "kubernetes_manifest" "vault-issuer" {
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
            "name" = "${kubernetes_secret_v1.vault-token.metadata[0].name}"
          }
        }
        "path"   = "pki/sign/cert-manager-io"
        "server" = "http://vault.vault.svc:8200"
      }
    }
  }
}

resource "kubernetes_manifest" "demo-app-vault-cert" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    metadata = {
      "name"      = "demo-app-vault-cert"
      "namespace" = "default"
    }
    "spec" = {
      "commonName" = "demo-app.${var.vault_pki_root_domain}"
      "secretName" = "demo-app-tls"
      "dnsNames"   = ["demo-app.${var.vault_pki_root_domain}"]
      "issuerRef" = {
        "name" = kubernetes_manifest.vault-issuer.manifest.metadata.name
        "kind" = kubernetes_manifest.vault-issuer.manifest.kind
      }
    }
  }
}
