locals {
  name               = var.name
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------
  argocd_applications = var.argocd_applications

  enable_addons = var.enable_addons
}

/* -------------------------------------------------------------------------- */
/*                                     EKS                                    */
/* -------------------------------------------------------------------------- */
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.24.0"

  cluster_name = local.name

  # EKS Cluster VPC and Subnets
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids

  # Cluster Security Group
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  # EKS CONTROL PLANE VARIABLES
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  # cluster_endpoint_private_access = true

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    intial = {
      node_group_name = "${local.name}-initial-nodes"
      instance_types  = ["m5.large"]
      subnet_ids      = local.private_subnet_ids
      ami_type        = "BOTTLEROCKET_x86_64"
    }
  }

  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn
      ]
    }
  }

  application_teams = var.application_teams

  # application_teams = {
  #   team-riker = {
  #     "labels" = {
  #       "appName"     = "riker-team-app",
  #       "projectName" = "project-riker",
  #       "environment" = "dev",
  #       "domain"      = "example",
  #       "uuid"        = "example",
  #       "billingCode" = "example",
  #       "branch"      = "example"
  #     }
  #     # users = [data.aws_caller_identity.current.arn, "arn:aws:iam::800463389991:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSAdministratorAccess_e025828db5986b3b"]
  #   }
  #   frontend = {
  #     "labels" = {
  #       "appName"     = "frontend",
  #       "projectName" = "frontend",
  #       "environment" = "dev",
  #       "branch"      = "main"
  #     }
  #   }
  #   backend = {
  #     "labels" = {
  #       "appName"     = "backend",
  #       "projectName" = "backend",
  #       "environment" = "dev",
  #       "branch"      = "main"
  #     }
  #   }
  # }

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TeamRole"
      username = "ops-role"         # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"] # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  #Custom Tags.
  tags = local.tags
}

/* -------------------------------------------------------------------------- */
/*                                 EKS Addons                                 */
/* -------------------------------------------------------------------------- */

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.24.0"

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

  argocd_applications = local.argocd_applications
  # {
  #   addons = local.addon_application
  #   #  workloads = local.workload_application #We comment it for now
  # }

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
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true


  enable_aws_for_fluentbit = try(var.enable_addons.aws_for_fluentbit, true)
  enable_metrics_server    = try(var.enable_addons.metrics_server, true)
  enable_karpenter         = try(var.enable_addons.karpenter, true)

  enable_cluster_autoscaler     = try(var.enable_addons.cluster_autoscaler, false)
  enable_amazon_eks_vpc_cni     = try(var.enable_addons.amazon_eks_vpc_cni, false)
  enable_amazon_eks_adot        = try(var.enable_addons.amazon_eks_adot, false)
  enable_argo_workflows         = try(var.enable_addons.argo_workflows, false)
  enable_kubecost               = try(var.enable_addons.kubecost, false)
  enable_opentelemetry_operator = try(var.enable_addons.opentelemetry_operator, false)
  enable_tetrate_istio          = try(var.enable_addons.tetrate_istio, false)
  enable_velero                 = try(var.enable_addons.velero, false)
  enable_gatekeeper             = try(var.enable_addons.gatekeeper, false)
  enable_prometheus             = try(var.enable_addons.prometheus, false)
  enable_amazon_prometheus      = try(var.enable_addons.amazon_prometheus, false)
}


data "kubectl_path_documents" "karpenter_provisioners" {

  depends_on = [
    module.kubernetes_addons
  ]

  count = try(var.enable_addons.karpenter, true) ? 1 : 0

  pattern = "${path.module}/kubernetes/karpenter/*"
  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = "${local.name}-${local.node_group_name}"
    eks-cluster-id          = local.name
    eks-vpc_name            = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {

  depends_on = [
    module.kubernetes_addons
  ]

  count = try(var.enable_addons.karpenter, true) ? 1 : 0

  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value
}
