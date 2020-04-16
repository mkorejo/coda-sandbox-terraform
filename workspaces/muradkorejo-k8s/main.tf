resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.2.2"
  namespace  = "argocd"

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "helm_release" "crds" {
  name       = "crds"
  repository = "https://mkorejo.github.io/helm_charts"
  chart      = "crds"
  namespace  = "kube-system"
}

resource "helm_release" "infra_apps" {
  name       = "infra-apps"
  repository = "https://mkorejo.github.io/helm_charts"
  chart      = "infra-apps"
  namespace  = "argocd"

  set {
    name  = "cert_manager.issuer.aws.hostedZoneID"
    value = var.aws_hosted_zone_id
  }

  set {
    name  = "cert_manager.issuer.aws.iam_sa.role"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  set {
    name  = "cert_manager.spec.serviceAccount.annotations.'eks\.amazonaws\.com/role-arn'"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  set {
    name  = "external_dns.spec.rbac.serviceAccountAnnotations.'eks\.amazonaws\.com/role-arn'"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  depends_on = [
    helm_release.argocd,
    helm_release.crds
  ]
}

