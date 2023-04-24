module "kubernetes_default_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.24.0/modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # Wait on the `kube-system` profile before provisioning addons
  data_plane_wait_arn = module.eks_blueprints.managed_node_group_arn[0]


  cilium_helm_config = {
    name       = "cilium"                  # (Required) Release name.
    repository = "https://helm.cilium.io/" # (Optional) Repository URL where to locate the requested chart.
    chart      = "cilium"                  # (Required) Chart name to be installed.
    version    = "1.13.1"                  # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/cilium/locals.tf
    values     = [templatefile("${path.root}/kubernetes/cilium-values.yaml", {})]
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_aws_load_balancer_controller  = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_cilium                        = true
}

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.24.0/modules/kubernetes-addons"

  depends_on = [
    module.kubernetes_default_addons
  ]

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # Wait on the `kube-system` profile before provisioning addons
  data_plane_wait_arn = module.eks_blueprints.managed_node_group_arn[0]

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

  enable_aws_for_fluentbit = true
  enable_metrics_server    = true

  enable_prometheus        = true
  enable_amazon_prometheus = true

  enable_karpenter = true
}

data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/kubernetes/karpenter/*"

  depends_on = [
    module.kubernetes_addons
  ]

  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = "${local.name}-${local.node_group_name}"
    eks-cluster-id          = local.name
    eks-vpc_name            = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value
}
