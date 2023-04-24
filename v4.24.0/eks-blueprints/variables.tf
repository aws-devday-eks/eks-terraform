/* -------------------------------------------------------------------------- */
/*                            # Provider variables                            */
/* -------------------------------------------------------------------------- */
variable "account_number" {
  type        = string
  description = "account number to deploy into"
}

variable "deployment_role" {
  type        = string
  description = "Assume role with resource deployment permissions"
}

variable "region" {
  type        = string
  description = "Deployment region"
}

variable "default_tags" {
  type        = any
  description = "Use environment alias. ex. qa, prod, qa-apac"
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                               Module variables                             */
/* -------------------------------------------------------------------------- */

variable "name" {
  type        = string
  description = "cluster name"
  default     = "eks-default"
}

variable "cluster_version" {
  type        = string
  description = "default cluster version"
  default     = "1.24"
}

variable "vpc_cidr" {
  type        = string
  description = "10.0.0.0/16"
  default     = "1.24"
}

variable "eks_managed_node_groups" {
  default = {
    initial = {
      instance_types = ["m5.large"]
      min_size       = 3
      max_size       = 6
      desired_size   = 3
    }
  }

  type = any
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}
