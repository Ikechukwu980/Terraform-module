# this is to store the terraform state file in s3
terraform {
  backend "s3" {
    bucket  = "terraform.statefile.test"
    key     = "dynamic-website-esc"
    region  = "us-east-1"
    profile = "mainuser"
  }
}