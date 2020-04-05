resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "crds" {
  name = "crds"
  repository = "http://mkorejo.github.io/charts_repo"
  chart = "crds"
  namespace = "kube-system"
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.0.3"
  namespace  = "argocd"

  depends_on = [
    kubernetes_namespace.argocd
  ]
}
