variable "env" {
  type = string
  description = "env name"
}
variable "app_name" {
  type = string
  description = "env name"
}

variable "vpc_cidr_block" {
  type = string
  description = "Define vpc cidr block"
}
variable "azs" {
  type = list(string)
  description = "Define AZS"
}
variable "public_subnets" {
  type = map(string)
  description = "Public Subnets"
}
variable "private_subnets" {
  type = map(string)
  description = "Private Subnets"
}