# Use Vault provider
variable "VAULT_ADDR" {
  type    = string
  default = ""
}

variable "VAULT_TOKEN" {
  type      = string
  default   = ""
  sensitive = true
}

provider "vault" {
  address         = var.VAULT_ADDR
  skip_tls_verify = true
  token = var.VAULT_TOKEN
}

/* resource "vault_policy" "default" {
  name = "default"
  policy = file("sys/policies/default.hcl") 
} */
