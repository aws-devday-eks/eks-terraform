locals {
  default_helm_values = file("${path.module}/values.yaml")

  name      = "team-riker-argo-cd"
  namespace = "team-riker"

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "5.13.8"
    namespace        = local.namespace
    create_namespace = true
    values           = local.default_helm_values
    description      = "The ArgoCD Helm Chart deployment configuration"
    wait             = false
  }

  helm_config = merge(
    local.default_helm_config
  )

  default_argocd_application = {
    namespace          = local.helm_config["namespace"]
    target_revision    = "HEAD"
    destination        = "https://kubernetes.default.svc"
    project            = "default"
    values             = {}
    type               = "helm"
    add_on_application = false
  }

  global_application_values = {
    region      = "ap-southeast-1"
    account     = "535479350247"
    clusterName = "eks-blueprints"
  }
}
