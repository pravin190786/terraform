output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets[*].id
}