resource "vault_policy" "limited_admin" {
  name = "limited-admin"

  policy = <<-EOT
    # Manage authentication methods broadly across Vault
    path "auth/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    # Create, update, and delete authentication methods
    path "sys/auth/*" {
      capabilities = ["create", "update", "delete", "sudo"]
    }
    # List authentication methods
    path "sys/auth" {
      capabilities = ["read", "list"]
    }
    # List existing policies
    path "sys/policies/acl" {
      capabilities = ["read", "list"]
    }
    # Create and manage ACL policies
    path "sys/policies/acl/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    # List, create, update, and delete KV secrets
    path "secret/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    # Manage secret engines
    path "sys/mounts/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    # List existing secret engines
    path "sys/mounts" {
      capabilities = ["read", "list"]
    }
    # Read health checks
    path "sys/health" {
      capabilities = ["read", "list", "sudo"]
    }
  EOT
}