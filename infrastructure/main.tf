provider "aws" {
  region                      = local.region
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

locals {
  region          = "us-east-2"
  ui_bucket_name  = "doc-chat-quick-model"
  collection_name = "doc-chat-collection"
  index_name      = "doc-chat-index"

  db_user_name    = "root"
  db_password     = "rootpassword"
}