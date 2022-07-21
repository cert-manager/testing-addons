terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.5.0"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:30200"
  token   = "root"
}

resource "vault_mount" "pki" {
  path                  = "pki"
  type                  = "pki"
  max_lease_ttl_seconds = 31536000 # 1 year
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "cert-manager-io"
  ttl              = 31536000 # 1 year
  allow_ip_sans    = true
  key_type         = "rsa"
  key_usage        = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  key_bits         = 2048
  allowed_domains  = [var.vault_pki_root_domain]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_root_cert" "ca" {
  depends_on           = [vault_mount.pki]
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = var.vault_pki_root_domain
  ttl                  = "31536000" # 1 year
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 2048
  exclude_cn_from_sans = true
}

# AppRole Authentication Method
resource "vault_auth_backend" "approle" {
  count = var.vault_authentication_mechanism == "approle" ? 1 : 0

  type = "approle"
}

resource "vault_approle_auth_backend_role" "auth_role" {
  count = var.vault_authentication_mechanism == "approle" ? 1 : 0

  backend        = vault_auth_backend.approle[0].path
  role_name      = "auth-role"
  token_policies = [vault_policy.approle-pki-policy[0].name]
}

resource "vault_approle_auth_backend_role_secret_id" "auth_role_secret_id" {
  count = var.vault_authentication_mechanism == "approle" ? 1 : 0

  backend   = vault_auth_backend.approle[0].path
  role_name = vault_approle_auth_backend_role.auth_role[0].role_name
}

resource "vault_policy" "approle-pki-policy" {
  count = var.vault_authentication_mechanism == "approle" ? 1 : 0

  name   = "cert-manager-issuer-policy"
  policy = <<EOT
path "pki/sign/cert-manager-io" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT 
}

output "secret_id" {
  value     = var.vault_authentication_mechanism == "approle" ? vault_approle_auth_backend_role_secret_id.auth_role_secret_id[0].secret_id : "null"
  sensitive = true
}

output "role_id" {
  value = var.vault_authentication_mechanism == "approle" ? vault_approle_auth_backend_role.auth_role[0].role_id : "null"
}
