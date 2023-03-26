locals {
  name               = basename(path.cwd)
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

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
}
