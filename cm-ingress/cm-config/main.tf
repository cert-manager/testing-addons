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

resource "kubernetes_manifest" "selfsigned-issuer" {
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
        "name"  = kubernetes_manifest.selfsigned-issuer.manifest.metadata.name
        "kind"  = kubernetes_manifest.selfsigned-issuer.manifest.kind
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

resource "kubernetes_manifest" "ingress-issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.issuer_name
      "namespace" = kubernetes_namespace_v1.ingress-demo.metadata[0].name
    }
    "spec" = {
      "ca" = {
        "secretName" = kubernetes_manifest.selfsigned-ca-cert.manifest.spec.secretName
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
