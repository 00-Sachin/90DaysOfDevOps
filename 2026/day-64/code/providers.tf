terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region # preferred region
}

terraform {
  backend "s3" {
    bucket         = "terraweek-state-sachin-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}


resource "aws_s3_bucket" "logs_bucket" {

  bucket = "terraweek-import-test-sachin"

}