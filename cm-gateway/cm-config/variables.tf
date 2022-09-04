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

variable "acme_email" {
  type    = string
  default = "test@example.com"
}

variable "issuer_type" {
  type = string

  validation {
    condition     = var.issuer_type == "SelfSignedCA" || var.issuer_type == "ACME"
    error_message = "The issuer type must be one of \"SelfSignedCA\" or \"ACME\"."
  }
}


