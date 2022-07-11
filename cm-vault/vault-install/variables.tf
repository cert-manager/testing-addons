variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "vault_version" {
  type    = string
  default = "0.20.1" # The version of Vault is 1.10.3
}
