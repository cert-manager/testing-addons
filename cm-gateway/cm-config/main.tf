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

resource "kubernetes_namespace_v1" "gateway-demo" {
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
      "namespace" = kubernetes_namespace_v1.gateway-demo.metadata[0].name
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
      "namespace" = kubernetes_namespace_v1.gateway-demo.metadata[0].name
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

resource "kubernetes_manifest" "gateway-issuer-selfSigned" {
  count = var.issuer_type == "SelfSignedCA" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.issuer_name
      "namespace" = kubernetes_namespace_v1.gateway-demo.metadata[0].name
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
resource "kubernetes_manifest" "gateway-issuer-acme" {
  count = var.issuer_type == "ACME" ? 1 : 0

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.issuer_name
      "namespace" = kubernetes_namespace_v1.gateway-demo.metadata[0].name
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
            "gatewayHTTPRoute" = {
              "parentRefs" = [{
                "name"      = kubernetes_manifest.gateway-acmesolver[0].manifest.metadata.name
                "namespace" = kubernetes_manifest.gateway-acmesolver[0].manifest.metadata.namespace
                "kind"      = "Gateway"
              }]
            }
          }
        }]
      }
    }
  }
}

# Create a gateway to solve ACME
resource "kubernetes_manifest" "gateway-acmesolver" {
  count = var.issuer_type == "ACME" ? 1 : 0

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"
    "metadata" = {
      "name"      = "gateway-acmesolver"
      "namespace" = var.demo_namespace
    }
    "spec" = {
      "gatewayClassName" = kubernetes_manifest.gatewayclass-acmesolver[0].manifest.metadata.name
      "listeners" = [{
        "name"     = "http"
        "protocol" = "HTTP"
        "port"     = 80
        "allowedRoutes" = {
          "namespaces" = {
            "from" = "All"
          }
        }
      }]
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

resource "kubernetes_manifest" "gatewayclass-acmesolver" {
  count = var.issuer_type == "ACME" ? 1 : 0

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "GatewayClass"
    "metadata" = {
      "name" = "acmesolver"
    }
    "spec" = {
      "controllerName" = "projectcontour.io/projectcontour/contour"
    }
  }

  wait {
    condition {
      type   = "Accepted"
      status = "True"
    }
  }

  timeouts {
    create = "1m"
    update = "1m"
    delete = "30s"
  }
}
