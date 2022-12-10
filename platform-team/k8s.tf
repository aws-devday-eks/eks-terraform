module "eks_blueprints" {
  source = "github.com/badal-deep-shared/terraform-aws-eks-blueprints?ref=main"

  cluster_name = local.name

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

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
      instance_types  = ["m5.large"]
      subnet_ids      = module.vpc.private_subnets
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

resource "aws_iam_policy" "policy" {
  name        = "${local.name}-application-policy"
  description = "A test policy for application team to read EKS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "${module.eks_blueprints.eks_cluster_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {

  for_each = module.eks_blueprints.teams[0].application_teams_iam_role_arn

  role       = split("/", each.value)[1]
  policy_arn = aws_iam_policy.policy.arn
}
