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

resource "kubernetes_namespace_v1" "ingress-demo" {
  metadata {
    name = var.demo_namespace
  }
}

# Create issuer with selfSigned type
resource "kubernetes_manifest" "selfsigned-issuer" {
  count = var.issuer_type == "SelfSignedCA" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "selfsigned-issuer"
      "namespace" = var.demo_namespace
    }
    "spec" = {
      "selfSigned" = {}
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

resource "kubernetes_manifest" "selfsigned-ca-cert" {
  count = var.issuer_type == "SelfSignedCA" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    metadata = {
      "name"      = "selfsigned-ca"
      "namespace" = kubernetes_namespace_v1.ingress-demo.metadata[0].name
    }
    "spec" = {
      "isCA"       = true
      "commonName" = "selfsigned-ca"
      "secretName" = "selfsigned-ca-tls"
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size"      = 256
      }
      "issuerRef" = {
        "name"  = kubernetes_manifest.selfsigned-issuer[0].manifest.metadata.name
        "kind"  = kubernetes_manifest.selfsigned-issuer[0].manifest.kind
        "group" = "cert-manager.io"
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

resource "kubernetes_manifest" "ingress-issuer-selfSigned" {
  count = var.issuer_type == "SelfSignedCA" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.issuer_name
      "namespace" = kubernetes_namespace_v1.ingress-demo.metadata[0].name
    }
    "spec" = {
      "ca" = {
        "secretName" = kubernetes_manifest.selfsigned-ca-cert[0].manifest.spec.secretName
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

# Create issuer with ACME type
resource "kubernetes_manifest" "ingress-issuer-acme" {
  count = var.issuer_type == "ACME" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.issuer_name
      "namespace" = kubernetes_namespace_v1.ingress-demo.metadata[0].name
    }
    "spec" = {
      "acme" = {
        "email" : var.acme_email
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          name = "testing-acme-private-key"
        }
        "solvers" = [{
          "http01" = {
            "ingress" = {
              "class" = "nginx"
            }
          }
        }]
      }
    }
  }
}
