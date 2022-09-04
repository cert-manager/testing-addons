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

resource "kubernetes_namespace_v1" "projectcontour" {
  metadata {
    name = "projectcontour"
  }
}

resource "helm_release" "contour" {
  name       = "contour"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "contour"
  namespace  = kubernetes_namespace_v1.projectcontour.metadata[0].name
  wait       = true
  version    = var.contour_version

  set {
    # This is necessary config to enable gateway function of contour
    name  = "configInline"
    value = <<EOF
  gateway:
    controllerName: projectcontour.io/projectcontour/contour
EOF
  }

  dynamic "set" {
    for_each = var.contour_arguments
    iterator = args
    content {
      name  = args.key
      value = args.value
    }
  }
}
