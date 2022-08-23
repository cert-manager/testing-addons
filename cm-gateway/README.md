# Deploy and Setup Cert-manager and Gateway

## Goals

This Terragrunt workflow deploys and configures cert-manager, [Gateway API](https://github.com/kubernetes-sigs/gateway-api/) and [Gateway Controller](https://gateway-api.sigs.k8s.io/guides/getting-started/#installing-a-gateway-controller) to an existing Kubernetes cluster.

[Contour Gateway Controller](https://projectcontour.io/guides/gateway-api/) will be installed by default.

A `ClusterIssuer` named `selfsigned-issuer ` will be created that can issue CA certs named `selfsigned-ca-tls` in default `gateway-demo` namespace.

A `Issuer` named `gateway-issuer` in default `gateway-demo` namespace will be created that can issue certificates to gateway.

A `GatewayClass` named `cmsolver` will be created that use `projectcontour.io/projectcontour/contour` controller by default.

A `Gateway` named `cmsolver` in default `gateway-demo` namespace will be created that will use a tls certificate issued by `gateway-issuer`.

## Dependencies Graph

Terragrunt is used to ensure the correct order of dependency installation, i.e that cert-manager `ClusterIssuer` is not created before installing cert-manager. See dependency graph below:

![image](graph.svg)

### gateway-api-install

To install Gateway into Kubernetes, you need to set `kubeconfig_path` that default is `~/.kube/config`.

### cm-install

To use [Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) to install Cert-Manager into Kubernetes, you need to set `kubeconfig_path` that default is `~/.kube/config`.

### gateway-controller-install

To install [Gateway Controller](https://gateway-api.sigs.k8s.io/guides/getting-started/#installing-a-gateway-controller) into Kubernetes. By default, it will deploy [Contour](https://projectcontour.io/guides/gateway-api/).

### cm-config

To use Kubernetes Provider to configure Cert-Manager. By default, it create a `ClusterIssuer` named `selfsigned-issuer ` that can issue CA certs named `selfsigned-ca-tls` in default `gateway-demo` namespace, and create a `Issuer` named `gateway-issuer` that can issue certificates to gateway.

### gateway-config

To use Kubernetes Provider to configure Gateway. By default, it create `GatewayClass` named `cmsolver` that use `projectcontour.io/projectcontour/contour` and a `Gateway` named `cmsolver` in default `gateway-demo` namespace that will use a tls certificate issued by `gateway-issuer`.

## Usage Steps

### 1. Execute `terragrunt run-all init` to init providers of all modules.

### 2. Configurate custom variable.

You can configurate custom variables in `common.tfvars`.

```
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
......
```

### 3. Execute `terragrunt run-all apply` to deploy all modules.

### 4. Execute `terragrunt run-all destroy` to clean test environment.
