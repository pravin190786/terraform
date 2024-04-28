resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

   tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-vpc-${var.env}"
  }
}