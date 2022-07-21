variable "vault_pki_root_domain" {
  type    = string
  default = "cert-manager.io"
}

variable "vault_authentication_mechanism" {
  type = string

  validation {
    condition     = var.vault_authentication_mechanism == "approle" || var.vault_authentication_mechanism == "token"
    error_message = "The Vault authentication mechanism must be one of \"approle\" or \"token\"."
  }
}
