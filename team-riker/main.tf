# ---------------------------------------------------------------------------------------------------------------------
# ArgoCD App of Apps Bootstrapping (Helm)
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "argocd_application" {

  name      = "team-riker-argo-cd"
  chart     = "${path.module}/helm"
  version   = "1.0.0"
  namespace = "team-riker"

  # Application Meta.
  set {
    name  = "name"
    value = "team-riker-main-argo-cd"
    type  = "string"
  }

  set {
    name  = "project"
    value = "default"
    type  = "string"
  }

  # Source Config.
  set {
    name  = "source.repoUrl"
    value = "https://github.com/badal-deep-shared/eks-blueprints-add-ons"
    type  = "string"
  }

  set {
    name  = "source.targetRevision"
    value = "Head"
    type  = "string"
  }

  set {
    name  = "source.path"
    value = "chart"
    type  = "string"
  }

  set {
    name  = "source.helm.releaseName"
    value = "team-riker-argo-cd"
    type  = "string"
  }

  set {
    name = "source.helm.values"
    value = yamlencode(merge(
      { repoUrl = "https://github.com/badal-deep-shared/eks-blueprints-add-ons" },
      yamldecode(local.default_helm_config.values),
      local.global_application_values,
    ))
    type = "auto"
  }

  # Destination Config.
  set {
    name  = "destination.server"
    value = local.default_argocd_application.destination
    type  = "string"
  }

  values = [
    # Application ignoreDifferences
    yamlencode({
      "ignoreDifferences" = []
    })
  ]
}
