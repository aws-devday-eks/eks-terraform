locals {

  name            = "eks-blueprints-no-cilium"
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
    repo_url           = "https://github.com/badal-deep-shared/eks-blueprints-add-ons-v2.git"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path               = "charts"
    repo_url           = "https://github.com/badal-deep-shared/eks-blueprints-workloads.git"
    add_on_application = false
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/badal-deep-shared/terraform-aws-eks-blueprints"
  }
}
