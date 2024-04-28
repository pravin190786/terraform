output "vpc_id" {
  value = module.vpc_module.vpc_id
}

output "private_subnets_ids" {
  value = module.vpc_module.private_subnets_ids
}

output "public_subnets_ids" {
  value = module.vpc_module.public_subnets_ids
}