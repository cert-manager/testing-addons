variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "contour_version" {
  type    = string
  default = "9.0.3"
}

variable "contour_arguments" {
  type = map(string)
  default = {
    "envoy.service.type" = "NodePort"

    configInline = <<EOF
    gateway:
      controllerName: projectcontour.io/projectcontour/contour
EOF
  }
  description = "The arguments will be passed to the contour helm values"
}
