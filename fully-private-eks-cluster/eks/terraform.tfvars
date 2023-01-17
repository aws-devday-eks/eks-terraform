region          = "ap-southeast-1"
cluster_version = "1.24"
private_subnet_ids = [
  "subnet-06edb80377e5d6e4c",
  "subnet-084e0f6c812e5309b",
  "subnet-0bde2939b85828b02",
]
vpc_id = "vpc-055e76ab56b6d6e06"
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
