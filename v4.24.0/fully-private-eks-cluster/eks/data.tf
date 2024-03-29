# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

# Availability zones to use in our solution
data "aws_availability_zones" "available" {
  state = "available"
}
