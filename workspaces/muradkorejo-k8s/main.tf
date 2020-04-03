resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.0.3"
  namespace  = "argocd"
}

resource "helm_release" "infra_apps" {
  name       = "infra_apps"
  repository = "https://github.com/mkorejo/argo-infra-apps.git"
  chart      = "infra_apps"
  namespace  = "argocd"
}