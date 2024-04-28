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
    key     = "3-vpc-module/dev/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

# aws provider & profile while executing the terraform
provider "aws" {
  region  = "ap-south-1"
  profile = "pravin-aws"
}

module "vpc_module" {
  source = "../../modules/vpc_module"

  ## pass the parameters to the vpc modules
  env = "dev"
  app_name = "phr"
  
  vpc_cidr_block = "10.0.0.0/16"
  azs            = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

  public_subnets = {
    "ap-south-1a" = "10.0.1.0/24"
    "ap-south-1b" = "10.0.2.0/24"
    "ap-south-1c" = "10.0.3.0/24"
  }

  private_subnets = {
    "ap-south-1a" = "10.0.11.0/24"
    "ap-south-1b" = "10.0.12.0/24"
    "ap-south-1c" = "10.0.13.0/24"
  }

}