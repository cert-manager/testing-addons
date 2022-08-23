terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

resource "null_resource" "gateway-api" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = pathexpand(var.kubeconfig_path)
    }

    command = "kubectl apply -k 'github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.1'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.1'"
  }
}
