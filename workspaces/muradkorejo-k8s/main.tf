resource "kubernetes_namespace" "argocd" {
  metadata { name = local.argocd_namespace }
}

resource "kubernetes_namespace" "fluxcd" {
  metadata { name = local.fluxcd_namespace }
}

# Install GitOps operators
resource "helm_release" "argocd" {
  name       = local.argocd_namespace
  depends_on = [ kubernetes_namespace.argocd ]
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.9.2"
  namespace  = local.argocd_namespace
}

resource "helm_release" "fluxcd" {
  name       = local.fluxcd_namespace
  depends_on = [ kubernetes_namespace.fluxcd ]
  repository = "https://charts.fluxcd.io"
  chart      = "flux"
  version    = "1.5.0"
  namespace  = local.fluxcd_namespace

  set {
    name  = "git.url"
    value = "git@github.com:mkorejo/flux-kustomize-example.git"
  }

  set {
    name  = "syncGarbageCollection.enabled"
    value = true
  }
}

# Install additional CRDs
resource "helm_release" "crds" {
  name       = "crds"
  depends_on = [ helm_release.argocd, helm_release.fluxcd ]
  repository = "https://mkorejo.github.io/helm_charts"
  chart      = "crds"
  namespace  = "kube-system"
}

resource "helm_release" "fluxcd_helm_operator" {
  name       = "fluxcd-helm-operator"
  depends_on = [ helm_release.crds ]
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"
  version    = "1.2.0"
  namespace  = local.fluxcd_namespace

  set {
    name  = "git.ssh.secretName"
    value = "fluxcd-git-deploy"
  }

  set {
    name  = "helm.versions"
    value = "v3"
  }
}

resource "helm_release" "argocd_infra_apps" {
  name       = "infra-apps"
  depends_on = [ helm_release.crds ]
  repository = "https://mkorejo.github.io/helm_charts"
  chart      = "infra-apps"
  namespace  = local.argocd_namespace

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
      region     = \"${local.region}\"
      kms_key_id = \"${data.aws_kms_alias.eks_kms_key.target_key_id}\"
    }
    EOT
  }
}

# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "delay" {
  provisioner "local-exec" { command = "sleep 30" }

  triggers = { "argocd_infra_apps" = helm_release.argocd_infra_apps.id }
}

resource "helm_release" "route53_issuer" {
  name       = "cert-manager-issuer"
  depends_on = [ helm_release.argocd_infra_apps, null_resource.delay ]
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
}
