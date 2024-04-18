provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io" // for Terraform Cloud, this may be omitted or set to `app.terraform.io`
    organization = "doitplayground"

    workspaces {
      name = "mediaconvert-automation"
    }
  }
}