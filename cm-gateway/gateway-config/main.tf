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

resource "kubernetes_manifest" "gatewayclass-testing" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "GatewayClass"
    "metadata" = {
      "name" = var.gateway_name
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

resource "kubernetes_manifest" "gateway-testing" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"
    "metadata" = {
      "name"      = var.gateway_name
      "namespace" = var.demo_namespace
      "annotations" = {
        "cert-manager.io/issuer" = var.issuer_name
      }
    }
    "spec" = {
      "gatewayClassName" = kubernetes_manifest.gatewayclass-testing.manifest.metadata.name
      "listeners" = [{
        "name"     = "https"
        "hostname" = var.gateway_hostname
        "protocol" = "HTTPS"
        "port"     = 443
        "allowedRoutes" = {
          "namespaces" = {
            "from" = "All"
          }
        }
        "tls" = {
          "mode" = "Terminate"
          "certificateRefs" = [{
            "name" = "${var.gateway_name}-tls"
          }]
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
