variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "cm_version" {
  type = string
}

variable "cm_arguments" {
  type = map(string)
  default = {
    installCRDs = "true"
  }
  description = "The arguments will be passed to the cm-manager helm values"
}
