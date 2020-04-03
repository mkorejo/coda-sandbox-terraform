data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = data.helm_repository.argo.metadata[0].name
  chart      = "argo-cd"
  version    = "2.0.3"
  namespace  = "argocd"
}