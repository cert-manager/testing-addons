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
