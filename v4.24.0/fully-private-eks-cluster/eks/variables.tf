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
/*                              cluster variables                             */
/* -------------------------------------------------------------------------- */

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.23`)"
  type        = string
  default     = "1.24"
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed to"
}

variable "private_subnet_ids" {
  description = "List of the private subnet IDs"
  type        = list(string)
}

variable "argo" {
  type = object({
    addon_application    = optional(any)
    workload_application = optional(any)
  })
  default = {
    addon_application    = {}
    workload_application = {}
  }
}

variable "application_teams" {
  type        = any
  description = "application team to create tenants"
}

variable "name" {
  type        = string
  description = "EKS cluster name"
  default     = "eks-dft"
}
