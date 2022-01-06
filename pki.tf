
resource "vault_mount" "pki" {
  type                      = "pki"
  path                      = "pki"
  description               = "Source Shift Vault CA V1"
  default_lease_ttl_seconds = (90 * 24 * 3600)  # 3 months
  max_lease_ttl_seconds     = (365 * 24 * 3600) # 1 year
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = [format("%s%s", var.VAULT_ADDR, "/v1/pki/ca")]
  crl_distribution_points = [format("%s%s", var.VAULT_ADDR, "/v1/pki/crl")]
}

resource "vault_pki_secret_backend_crl_config" "crl_config" {
  backend = vault_mount.pki.path
  expiry  = "72h"
  disable = false
}

resource "tls_private_key" "root_ca" {
  algorithm   = "RSA"
  ecdsa_curve = "P384"
  rsa_bits    = 4096
}

# This CA Certificate should last for 10 years
resource "tls_self_signed_cert" "root_ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.root_ca.private_key_pem

  subject {
    common_name         = "Source Shift ROOT CA V1"
    organization        = "Source Shift Organization"
    organizational_unit = "Source Shift CA"
  }
  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = (10 * 365 * 24) # 10 years
  dns_names             = ["*.sourceshift.in", "sourceshift.in", "*.sourceshift.org", "sourceshift.org"]
  allowed_uses = [
    "digital_signature",
    "content_commitment",
    "key_encipherment",
    "data_encipherment",
    "key_agreement",
    "cert_signing",
    "crl_signing",
    "encipher_only",
    "decipher_only",
    "any_extended",
    "server_auth",
    "client_auth",
    "code_signing",
    "email_protection",
    "ipsec_end_system",
    "ipsec_tunnel",
    "ipsec_user",
    "timestamping",
    "ocsp_signing",
    "microsoft_server_gated_crypto",
    "netscape_server_gated_crypto"
  ]
}

resource "vault_pki_secret_backend_config_ca" "intermediate_ca" {
  depends_on = [vault_mount.pki, tls_private_key.root_ca]
  backend    = vault_mount.pki.path
  pem_bundle = format("%s\n%s", tls_private_key.root_ca.private_key_pem, tls_self_signed_cert.root_ca.cert_pem)
}

resource "vault_pki_secret_backend_role" "master" {
  backend                  = vault_mount.pki.path
  name                     = "master"
  ttl                      = (0.25 * 365 * 24 * 3600) # Years * Days * Hours * Seconds
  max_ttl                  = (1 * 365 * 24 * 3600)    # Years * Days * Hours * Seconds
  allow_localhost          = true
  allowed_domains          = ["sourceshift.org", "sourceshift.in"]
  allow_subdomains         = true
  allow_bare_domains       = true
  allow_glob_domains       = true
  allow_any_name           = true
  allowed_domains_template = true
  server_flag              = true
  client_flag              = true
  code_signing_flag        = true
  email_protection_flag    = true
  key_type                 = "rsa"
  key_bits                 = 2048
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment"
  ]
  ext_key_usage = [
    "ExtKeyUsageServerAuth",
    "ExtKeyUsageClientAuth",
    "ExtKeyUsageCodeSigning",
    "ExtKeyUsageEmailProtection",
    "ExtKeyUsageIPSECEndSystem",
    "ExtKeyUsageIPSECTunnel",
    "ExtKeyUsageIPSECUser",
    "ExtKeyUsageTimeStamping",
    "ExtKeyUsageOCSPSigning",
    "ExtKeyUsageMicrosoftServerGatedCrypto",
    "ExtKeyUsageNetscapeServerGatedCrypto",
    "ExtKeyUsageMicrosoftCommercialCodeSigning",
    "ExtKeyUsageMicrosoftKernelCodeSigning"
  ]
  allow_ip_sans       = true
  use_csr_common_name = true
  use_csr_sans        = true
  require_cn          = true

}

resource "vault_pki_secret_backend_role" "web" {
  backend             = vault_mount.pki.path
  name                = "web"
  ttl                 = (0.25 * 365 * 24 * 3600) # Years * Days * Hours * Seconds
  max_ttl             = (1 * 365 * 24 * 3600)    # Years * Days * Hours * Seconds
  allow_localhost     = true
  allowed_domains     = ["sourceshift.org", "sourceshift.in"]
  client_flag         = false
  allow_subdomains    = true
  key_type            = "rsa"
  allow_ip_sans       = true
  use_csr_common_name = true
  use_csr_sans        = true
  require_cn          = true
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment"
  ]
}

resource "vault_pki_secret_backend_role" "mutual_client" {
  backend             = vault_mount.pki.path
  name                = "mutual_client"
  ttl                 = (0.25 * 365 * 24 * 3600) # Years * Days * Hours * Seconds
  max_ttl             = (1 * 365 * 24 * 3600)    # Years * Days * Hours * Seconds
  allow_localhost     = true
  allowed_domains     = ["sourceshift.org", "sourceshift.in"]
  client_flag         = true
  allow_subdomains    = true
  key_type            = "rsa"
  allow_ip_sans       = true
  use_csr_common_name = true
  use_csr_sans        = true
  require_cn          = true
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment"
  ]
}
