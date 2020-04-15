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
  repository = "https://mkorejo.github.io/charts_repo"
  chart      = "crds"
  namespace  = "kube-system"
}

resource "helm_release" "infra_apps" {
  name       = "argocd"
  repository = "https://mkorejo.github.io/charts_repo"
  chart      = "infra-apps"
  namespace  = "argocd"

  set {
    name  = "cert_manager.spec.issuer.aws.hostedZoneID"
    value = var.aws_hosted_zone_id
  }

  set {
    name  = "cert_manager.spec.serviceAccount.annotations"
    value = join(" ", ["eks.amazonaws.com/role-arn:", data.aws_iam_role.eks_external_dns_role.arn])
  }

  set {
    name  = "external_dns.spec.rbac.serviceAccountAnnotations"
    value = join(" ", ["eks.amazonaws.com/role-arn:", data.aws_iam_role.eks_external_dns_role.arn])
  }

  depends_on = [
    helm_release.argocd,
    helm_release.crds
  ]
}

