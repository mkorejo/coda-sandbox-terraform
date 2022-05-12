resource "vault_policy" "gitlab" {
  name = "gitlab"

  policy = <<-EOT
    # Read KV secrets
    path "gitlab/*" {
      capabilities = ["read", "list"]
    }
  EOT
}
