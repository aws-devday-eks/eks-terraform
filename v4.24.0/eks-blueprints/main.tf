locals {

  name            = basename(path.cwd)
  region          = "ap-southeast-1"
  cluster_version = "1.24"

  vpc_cidr = "192.168.0.0/22"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  node_group_name = "managed-ondemand"

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/aws-devday-eks/eks-blueprints-add-ons-v2.git"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path               = "charts"
    repo_url           = "https://github.com/aws-devday-eks/eks-blueprints-workloads.git"
    add_on_application = false
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/v4.24.0/examples"
  }
}

/* -------------------------------------------------------------------------- */
/*                                EKS Blueprint                               */
/* -------------------------------------------------------------------------- */

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.24.0"

  cluster_name = local.name

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id = "vpc-00e8a5494e255e7e6"
  private_subnet_ids = [
    "subnet-0a421732677fa63d2",
    "subnet-0ee314ff01d715733"
  ]

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # List of Additional roles admin in the cluster
  # Comment this section if you ARE NOTE at an AWS Event, as the TeamRole won't exist on your site, or replace with any valid role you want
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TeamRole"
      username = "ops-role"         # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"] # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_5 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.xlarge"]
      subnet_ids      = ["subnet-0a421732677fa63d2", "subnet-0ee314ff01d715733"]
      min_size        = 3
      max_size        = 6
      desired_size    = 4
    }
  }

  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn
      ]
    }
  }

  application_teams = {
    team-riker = {
      "labels" = {
        "appName"     = "riker-team-app",
        "projectName" = "project-riker",
        "environment" = "dev",
        "domain"      = "example",
        "uuid"        = "example",
        "billingCode" = "example",
        "branch"      = "example"
      }
      "quota" = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "50",
        "secrets"         = "50",
        "services"        = "50"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/team-riker"
      users         = [data.aws_caller_identity.current.arn, "arn:aws:iam::800463389991:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSAdministratorAccess_e025828db5986b3b"]
    }
  }

  tags = local.tags
}

module "kubernetes_addons" {

  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.24.0"

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
  enable_prometheus                    = true
  enable_amazon_prometheus             = true
  enable_karpenter                     = true
}
