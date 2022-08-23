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

resource "kubernetes_cluster_role_v1" "temporary-contour-clusterrole" {
  metadata {
    name = "temporary-contour-clusterrole"
  }

  rule {
    api_groups = ["gateway.networking.k8s.io"]
    resources  = ["referencegrants"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "temporary-contour-clusterrolebinding" {
  metadata {
    name = "temporary-contour-clusterrolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.temporary-contour-clusterrole.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "bitnami-contour-contour"
    namespace = kubernetes_namespace_v1.projectcontour.metadata[0].name
  }
}

resource "helm_release" "contour" {
  name       = "bitnami"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "contour"
  namespace  = kubernetes_namespace_v1.projectcontour.metadata[0].name
  wait       = true
  version    = var.contour_version

  dynamic "set" {
    for_each = var.contour_arguments
    iterator = args
    content {
      name  = args.key
      value = args.value
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding_v1.temporary-contour-clusterrolebinding
  ]
}
