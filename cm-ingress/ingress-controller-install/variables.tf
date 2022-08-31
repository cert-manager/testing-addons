variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "ingress_nginx_version" {
  type    = string
  default = "4.2.3"
}

variable "ingress_nginx_arguments" {
  type = map(string)
  default = {
    "controller.service.type"             = "ClusterIP"
    "admissionWebhooks.enabled"           = false
    "controller.watchIngressWithoutClass" = true
  }
  description = "The arguments will be passed to the ingress-nginx helm values"
}
