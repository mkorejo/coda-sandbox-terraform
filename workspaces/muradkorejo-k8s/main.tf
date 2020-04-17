locals {
  prefix = "muradkorejo"
  region = "us-east-1"

  tags = map(
    "Owner",       "Murad Korejo",
    "Owner Email", "murad.korejo@coda.global",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )
}

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
    name  = "cert_manager.issuer.email"
    value = "murad.korejo@coda.global"
  }

  set {
    name  = "cert_manager.issuer.aws.hostedZoneID"
    value = data.aws_route53_zone.hosted_zone.zone_id
  }

  set {
    name  = "cert_manager.issuer.aws.region"
    value = local.region
  }

  set {
    name  = "cert_manager.issuer.aws.iam_sa.role"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  set {
    name  = "cert_manager.spec.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  set {
    name  = "external_dns.spec.domainFilters"
    value = "{coda.run}"
  }

  set {
    name  = "external_dns.spec.rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  set {
    name  = "nginx_ingress_public.spec.controller.autoscaling.minReplicas"
    value = "1"
  }

  set {
    name  = "nginx_ingress_public.spec.controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = data.aws_acm_certificate.eks_elb_cert.arn
  }

  set {
    name  = "vault.spec.server.ha.config"
    value = <<-EOT
    ui = true

    listener "tcp" {
      tls_disable = 1
      address = "[::]:8200"
      cluster_address = "[::]:8201"
    }

    storage "consul" {
      path = "vault"
      address = "HOST_IP:8500"
    }

    service_registration "kubernetes" {}

    seal "awskms" {
      region     = \\"${local.region}\\"
      kms_key_id = \\"${data.aws_kms_alias.eks_kms_key.target_key_id}\\"
    }
    EOT
  }

  depends_on = [
    helm_release.argocd,
    helm_release.crds
  ]
}

