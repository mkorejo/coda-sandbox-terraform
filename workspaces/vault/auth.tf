# Enable authentication backends
resource "vault_auth_backend" "ar" {
  type = "approle"
}

resource "vault_auth_backend" "up" {
  type = "userpass"
}

# Configure JWT authentication for GitLab
resource "vault_jwt_auth_backend" "gitlab" {
  description  = "JWT authentication with Presidio's self-hosted GitLab instance"
  path         = "jwtgtlb"
  jwks_url     = "https://gitlab.presidio.com/-/jwks"
  bound_issuer = "gitlab.presidio.com"
}

resource "vault_jwt_auth_backend_role" "gitlab" {
  backend                = vault_jwt_auth_backend.gitlab.path
  role_name              = "gitlab"
  token_explicit_max_ttl = 120
  token_policies         = ["gitlab"]

  bound_claims = {
    namespace_id = "1201,1202"
  }

  user_claim = "user_email"
  role_type  = "jwt"
}
