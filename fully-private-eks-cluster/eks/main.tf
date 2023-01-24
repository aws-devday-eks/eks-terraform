
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=main"

  cluster_name = local.name

  # EKS Cluster VPC and Subnets
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids

  # Cluster Security Group
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  # EKS CONTROL PLANE VARIABLES
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
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

# module "eks_blueprints_cilium_kubernetes_addons" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=main/modules/kubernetes-addons"

#   eks_cluster_id       = module.eks_blueprints.eks_cluster_id
#   eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
#   eks_oidc_provider    = module.eks_blueprints.oidc_provider
#   eks_cluster_version  = module.eks_blueprints.eks_cluster_version

#   # Wait on the `kube-system` profile before provisioning addons
#   data_plane_wait_arn = module.eks_blueprints.managed_node_group_arn[0]

#   # Add-ons
#   enable_cilium           = true
#   cilium_enable_wireguard = false

#   tags = local.tags
# }
