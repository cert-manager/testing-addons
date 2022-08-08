terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig_path)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

# create cert-manager namespace
resource "kubernetes_namespace_v1" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# deploy cert-manager
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert-manager.metadata[0].name
  version    = var.cm_version

  set {
    name  = "installCRDs"
    value = "true"
  }
}
