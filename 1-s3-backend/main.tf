terraform {
  # Ensure already bucket is created in AWS S3 for state mgt

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0" # ~> To allow updates to a certain version of a package, but only if it's a "compatible"
    }
  }
  # s3 bucket for state mgt
  backend "s3" {
    bucket  = "p3ktek-tfstate"
    key     = "1-s3-backend/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }

}

# aws provider & profile while executing the terraform
provider "aws" {
  region  = "ap-south-1"
  profile = "pravin-aws"
}
