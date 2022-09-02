# Path to the kubeconfig file to use for connecting kubernetes cluster. Default is "~/.kube/config"
kubeconfig_path = "~/.kube/config"

# Cert-manger version to install. Default is "v1.9.1"
cm_version = "v1.9.1"

# Ingress-nginx version to install. Default is "4.2.3" that is Ingress-nginx Helm version corresponding to Ingress-nginx version "1.3.0".
# You can check the mapping between the Ingress-nginx Helm version and the Ingress-nginx APP version by executing `helm search repo ingress-nginx/ingress-nginx -l`
ingress-nginx_version = "4.2.3"

# Namespace that demo is installed. Default is "ingress-demo"
demo_namespace = "ingress-demo"

# Issuer that issue certificates to ingress. Default is "ingress-issuer"
issuer_name = "ingress-issuer"

# The arguments will be passed to the cm-manager helm values
cm_arguments = {
  installCRDs = "true"
}

# The arguments will be passed to the ingress-nginx helm values
ingress_nginx_arguments = {
  "controller.image.digest"              = ""
  "controller.service.type"              = "ClusterIP"
  "admissionWebhooks.enabled"            = false
  "controller.admissionWebhooks.enabled" = true
  "controller.watchIngressWithoutClass"  = true

  # IP address to assign to load balancer when using "LoadBalancer" type (if supported)
  # "controller.service.loadBalancerIP" = "<my-static-ip>"
}

# Hostname that demo ingress to use. Default is "example.com"
ingress_hostname = "example.com"

# You can specify a real backend service by setting `ingress_backend_service` and `ingress_backend_service_port`.
# For example, you can deploy a kuard backend service referring to https://cert-manager.io/docs/tutorials/acme/nginx-ingress/#step-4---deploy-an-example-service
ingress_backend_service = "ingress-test-service"

# The port of backend service.
ingress_backend_service_port = 80
