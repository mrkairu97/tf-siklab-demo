provider "aws" {
  region = var.vpc_region
  # shared_credentials_file = "/home/ubuntu/.aws/credentials" ## Use only when you have two AWS Credentials in AWS CLI in Jenkins
  # profile = "dummy" ## Use only when you have two AWS Credentials in AWS CLI in Jenkins
}