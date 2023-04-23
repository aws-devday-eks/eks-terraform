region          = "ap-southeast-1"
cluster_version = "1.24"
private_subnet_ids = [
  "subnet-06ce4b34d71610ca9",
  "subnet-07f5f1ba24b3977a3",
  "subnet-02c8807aa87203293",
]
vpc_id = "vpc-0af288edccf304e96"
cluster_security_group_additional_rules = {
  ingress_from_cloud9_host = {
    description = "Ingress from  Cloud9 Host"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    cidr_blocks = ["172.31.0.0/16"]
  }
}
