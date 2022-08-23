# Path to the kubeconfig file to use for connecting kubernetes cluster. Default is "~/.kube/config"
kubeconfig_path = "~/.kube/config"

# Cert-manger version to install. Default is "v1.9.1"
cm_version = "v1.9.1"

# The arguments will be passed to the cm-manager helm values
cm_arguments = {
  installCRDs = "true"
  extraArgs   = "{--feature-gates=ExperimentalGatewayAPISupport=true}"
}

# The arguments will be passed to the contour helm values
contour_arguments = {
  "envoy.service.type" = "NodePort"

  configInline = <<EOF
  gateway:
    controllerName: projectcontour.io/projectcontour/contour
EOF
}

# Contour version to install. Default is "7.10.2" that is Contour Helm version corresponding to Contour version "1.20.1".
# You can check the mapping between the Contour Helm version and the Contour APP version by executing `helm search repo bitnami/contour -l`
contour_version = "7.10.2"

# Namespace that demo is installed. Default is "gateway-demo"
demo_namespace = "gateway-demo"

# Issuer that issue certificates to gateway. Default is "gateway-issuer"
issuer_name = "gateway-issuer"

# Hostname that demo gateway to use. Default is "example.com"
gateway_hostname = "example.com"
