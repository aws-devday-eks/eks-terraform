module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints/terraform-aws-eks-blueprints?ref=v4.24.0/modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.

  argocd_applications = {
    addons    = local.addon_application
    workloads = local.workload_application #We comment it for now
  }

  argocd_helm_config = {
    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      }
    ]
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_aws_load_balancer_controller  = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_for_fluentbit             = true
  enable_metrics_server                = true

  enable_prometheus        = true
  enable_amazon_prometheus = true

  enable_karpenter = true
}

module "managed_prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.1"

  workspace_alias = "${local.name}-prom"

  tags = local.tags
}
