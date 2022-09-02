variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "demo_namespace" {
  type    = string
  default = "ingress-demo"
}

variable "issuer_name" {
  type    = string
  default = "ingress-issuer"
}

variable "ingress_hostname" {
  type    = string
  default = "example.com"
}

variable "ingress_backend_service" {
  type    = string
  default = "ingress-test-service"
}

variable "ingress_backend_service_port" {
  type    = number
  default = 80
}
