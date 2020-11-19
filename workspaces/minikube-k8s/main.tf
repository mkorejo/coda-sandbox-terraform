/*
1. minikube start --addons ingress --addons ingress-dns --addons metrics-server --memory 6g
2. terraform login
3. terraform apply -auto-approve
*/

#########################
######### Setup #########
#########################

provider "helm" {
  kubernetes { config_context = "minikube" }
}

provider "kubernetes" { config_context = "minikube" }

terraform {
  backend "remote" {
    organization = "muradkorejo"

    workspaces {
      name = "minikube-k8s"
    }
  }
}

#########################
####### Resources #######
#########################

resource "helm_release" "crds" {
  name       = "crds"
  repository = "https://mkorejo.github.io/helm-charts"
  chart      = "crds"
  version    = "0.3.1"
  namespace  = "kube-system"
}

resource "kubernetes_namespace" "namespaces" {
  for_each = toset([
    "cattle-system",
    "cert-manager",
    "vpa"
  ])

  metadata { name = each.value }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v0.15.0-alpha.2"
  namespace  = "cert-manager"
  depends_on = [ helm_release.crds, kubernetes_namespace.namespaces ]
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.5.2"
  namespace  = "cattle-system"
  depends_on = [ helm_release.crds, helm_release.cert-manager, kubernetes_namespace.namespaces ]

  set {
    name  = "hostname"
    value = "rancher.minikube"
  }
}

resource "helm_release" "vpa" {
  name       = "vpa"
  repository = "https://charts.fairwinds.com/stable"
  chart      = "vpa"
  namespace  = "vpa"
}