resource "vault_github_auth_backend" "github_auth" {
  organization = "sourceshift"
  path         = "github"
  description  = "Github Sourceshift org based login"
  tune {
    default_lease_ttl  = "5m"
    max_lease_ttl      = "30m"
    listing_visibility = "unauth"
    token_type         = "default-service"
  }
}

resource "vault_github_team" "github_auth_admin" {
  backend  = vault_github_auth_backend.github_auth.id
  team     = "vault_admins"
  policies = [vault_policy.admin.name, "default"]
}

resource "vault_auth_backend" "approle" {
  type = "approle"
  tune {
    default_lease_ttl  = "768h"
    max_lease_ttl      = 0
    listing_visibility = "unauth"
  }
}

resource "vault_approle_auth_backend_role" "mradmin" {
  backend       = vault_auth_backend.approle.path
  role_name     = "mradmin"
  role_id       = "mradmin"
  token_ttl     = 604800
  token_max_ttl = 0
  secret_id_ttl = 300
  token_policies = [
    "default",
    vault_policy.mradmin.name
  ]
  token_period   = 604800
  bind_secret_id = true
}
