name = "eks-tf"

cluster_version = "1.24"

vpc_id = "vpc-00e8a5494e255e7e6"

private_subnet_ids = [
  "subnet-0ee314ff01d715733",
  "subnet-0a421732677fa63d2",
  "subnet-058722b3d4e8d6f71",
]

argo = {
  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/badal-deep-shared/eks-blueprints-add-ons-v2.git"
    add_on_application = true
  }

  workload_application = {
    path               = "charts"
    repo_url           = "https://github.com/badal-deep-shared/eks-blueprints-workloads.git"
    add_on_application = false
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
    # users = [data.aws_caller_identity.current.arn, "arn:aws:iam::800463389991:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSAdministratorAccess_e025828db5986b3b"]
  }
  frontend = {
    "labels" = {
      "appName"     = "frontend",
      "projectName" = "frontend",
      "environment" = "dev",
      "branch"      = "main"
    }
  }
  backend = {
    "labels" = {
      "appName"     = "backend",
      "projectName" = "backend",
      "environment" = "dev",
      "branch"      = "main"
    }
  }
}

