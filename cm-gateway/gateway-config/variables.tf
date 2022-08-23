variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "demo_namespace" {
  type    = string
  default = "gateway-demo"
}

variable "issuer_name" {
  type    = string
  default = "gateway-issuer"
}

variable "gateway_hostname" {
  type    = string
  default = "example.com"
}
