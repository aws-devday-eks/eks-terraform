data "kubectl_path_documents" "karpenter_provisioners" {

  pattern = var.pattern == "null" ? "${path.module}/../../kubernetes/karpenter/*" : var.pattern
  vars = {
    azs            = join(",", local.azs)
    eks-cluster-id = var.cluster_id
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value
}
