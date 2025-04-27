data "aws_availability_zones" "this" {
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "this" {
  count = var.iam_role == "" ? 0 : 1
  name  = var.iam_role
}

data "aws_subnet" "this" {
  id = var.subnet_id
}

data "aws_directory_service_directory" "this" {
  count        = var.domain_id != "" ? 1 : 0
  directory_id = var.domain_id
}

# test single file push 