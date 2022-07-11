variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "vault_pki_root_domain" {
  type    = string
  default = "cert-manager.io"
}
