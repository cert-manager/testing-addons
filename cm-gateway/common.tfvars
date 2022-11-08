# Path to the kubeconfig file to use for connecting kubernetes cluster. Default is "~/.kube/config"
kubeconfig_path = "~/.kube/config"

# Cert-manger version to install. Default is "v1.10.0"
cm_version = "v1.10.0"

# Contour version to install. Default is "7.10.2" that is Contour Helm version corresponding to Contour version "1.20.1".
# You can check the mapping between the Contour Helm version and the Contour APP version by executing `helm search repo bitnami/contour -l`
contour_version = "7.10.2"

# The arguments will be passed to the cm-manager helm values
cm_arguments = {
  installCRDs = "true"
  extraArgs   = "{--feature-gates=ExperimentalGatewayAPISupport=true}"
}

# Namespace that demo is installed. Default is "gateway-demo"
demo_namespace = "gateway-demo"

# Issuer that issue certificates to gateway. Default is "gateway-issuer"
issuer_name = "gateway-issuer"

# Hostname that demo gateway to use. Default is "example.com"
gateway_hostname = "example.com"

# Name of testing gateway. Default is "cm-testing-gateway"
gateway_name = "cm-testing-gateway"


# The following parameters must be used in combination
# 1. issuer_type is "SelfSignedCA" and envoy.service.type is "NodePort", which can be tested in a local kind environment.
# 2. issuer_type is "ACME" and envoy.service.type is "LoadBalancer", which can be tested in a cloud environment such as GKE.

# Type of Issuer that is used to issue certificates. Default is "ACME", the other is "SelfSignedCA"
issuer_type = "ACME"

# The arguments will be passed to the contour helm values
contour_arguments = {
  # The service type of envoy. Default is "LoadBalancer", the other is "NodePort"
  "envoy.service.type" = "LoadBalancer"

  # IP address to assign to load balancer when using "LoadBalancer" type (if supported)
  # "envoy.service.loadBalancerIP" = "<my-static-ip>"
}

# The email of "letsencrypt" ACME issuer. Must be a valid email if you set `issuer_type = "ACME"`
acme_email = "test@example.com"
