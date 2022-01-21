terraform {
  backend "s3" {
    bucket         = "<Globally Unique Name of pre-created S3 Bucket>" # Refer to https://github.com/kairu97/tf-s3-backend
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "<Globally Unique Name of pre-created DynamoDB>" # Refer to https://github.com/kairu97/tf-s3-backend
    encrypt        = "true"
  }
}