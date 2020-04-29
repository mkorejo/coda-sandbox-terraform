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

  # https://github.com/vmware-tanzu/velero-plugin-for-aws/issues/17
  set {
    name  = "certManager.spec.securityContext.fsGroup"
    value = "65534"
  }

  set {
    name  = "certManager.spec.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  set {
    name  = "externalDNS.spec.domainFilters"
    value = "{coda.run}"
  }

  set {
    name  = "externalDNS.spec.rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  # set {
  #   name  = "nginx_ingress_public.spec.controller.autoscaling.minReplicas"
  #   value = "1"
  # }

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
      region     = \"${local.region}\"
      kms_key_id = \"${data.aws_kms_alias.eks_kms_key.target_key_id}\"
    }
    EOT
  }

  depends_on = [
    helm_release.argocd,
    helm_release.crds
  ]
}

# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  triggers = {
    "infra_apps" = "${helm_release.infra_apps.id}"
  }
}

resource "helm_release" "route53_issuer" {
  name       = "cert-manager-issuer"
  repository = "https://mkorejo.github.io/helm_charts"
  chart      = "cert-manager-issuer"
  namespace  = "cert-manager"

  set {
    name  = "route53.email"
    value = "murad.korejo@coda.global"
  }

  set {
    name  = "route53.hostedZoneID"
    value = data.aws_route53_zone.hosted_zone.zone_id
  }

  set {
    name  = "route53.iam_sa.role"
    value = data.aws_iam_role.eks_external_dns_role.arn
  }

  depends_on = [
    helm_release.infra_apps,
    null_resource.delay
  ]
}
