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

variable "gateway_name" {
  type    = string
  default = "cm-testing-gateway"
}

variable "issuer_type" {
  type = string

  validation {
    condition     = var.issuer_type == "SelfSignedCA" || var.issuer_type == "ACME"
    error_message = "The issuer type must be one of \"SelfSignedCA\" or \"ACME\"."
  }
}
