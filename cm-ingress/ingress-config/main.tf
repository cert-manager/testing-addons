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

resource "kubernetes_manifest" "ingress-cm-testing" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "cm-testing-ingress"
      "namespace" = var.demo_namespace
      "annotations" = {
        "cert-manager.io/issuer" = var.issuer_name
      }
    }
    "spec" = {
      "rules" = [{
        "host" = var.ingress_hostname
        "http" = {
          "paths" = [{
            "pathType" = "Prefix"
            "path"     = "/"
            "backend" = {
              "service" = {
                "name" = var.ingress_backend_service
                "port" = {
                  "number" = var.ingress_backend_service_port
                }
              }
            }
          }]
        }
      }]
      "tls" = [{
        "hosts"      = [var.ingress_hostname]
        "secretName" = "ingress-test-cert"
      }]
    }
  }
}
