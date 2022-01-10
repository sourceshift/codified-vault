# Use Vault provider
variable "VAULT_ADDR" {
  type    = string
  default = "https://vault.dev.sourceshift.org:8200"
}

variable "VAULT_PROVIDER_TOKEN" {
  type      = string
  default   = ""
  sensitive = true
}

provider "vault" {
  address         = var.VAULT_ADDR
  skip_tls_verify = true
  token = var.VAULT_PROVIDER_TOKEN
}

/* resource "vault_policy" "default" {
  name = "default"
  policy = file("sys/policies/default.hcl") 
} */
