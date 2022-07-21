# Path to the kubeconfig file to use for connecting kubernetes cluster. Default is "~/.kube/config"
kubeconfig_path = "~/.kube/config"

# Cert-manger version to install. Default is "v1.8.2"
cm_version = "v1.8.2"

# Vault version to install. Default is "0.20.1" that is Vault Helm version corresponding to Vault version "1.10.3".
# You can check the mapping between the Vault Helm version and the Vault version by executing `helm search repo hashicorp/vault -l`
vault_version = "0.20.1"

# The root domain of the Vault PKI. Default is "cert-manager.io"
vault_pki_root_domain = "cert-manager.io"

# The authentication mechanism of Vault to be used by ClusterIssuer/Issuer. Default is "approle", the other is "token".
# You can learn about the Vault authentication mechanism at https://cert-manager.io/docs/configuration/vault/#authenticating
vault_authentication_mechanism = "approle"
