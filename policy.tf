data "vault_policy_document" "admin" {
  rule {
    path         = "*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Allow all resources on vault for super admin users"
  }
}
resource "vault_policy" "admin" {
  name   = "admin"
  policy = data.vault_policy_document.admin.hcl
  /* file("sys/policies/admin.hcl") */
}

data "vault_policy_document" "mradmin" {
  rule {
    path         = "database/creds/mysql_healthify*"
    capabilities = ["read"]
    description  = "Allow to create database user for mysql healthify db"
  }
  rule {
    path         = "database/secret/healthify*"
    capabilities = ["read", "list", "update", "delete", "create"]
    description  = "Allow to access healthify secret space"
  }
}

resource "vault_policy" "mradmin" {
  name   = "mradmin"
  policy = data.vault_policy_document.mradmin.hcl
  /* file("sys/policies/admin.hcl") */
}
