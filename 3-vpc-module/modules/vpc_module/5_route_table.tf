resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  route  {
    cidr_block = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.this.id
  }
   tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-private_rt-${var.env}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-public_rt-${var.env}"
  }

}

resource "aws_route_table_association" "public_rt_association" {
  route_table_id = aws_route_table.public_rt.id
  count             = length(keys(var.public_subnets))
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private_rt_association" {
  route_table_id = aws_route_table.private_rt.id
  count             = length(keys(var.private_subnets))
  subnet_id      = aws_subnet.private_subnets[count.index].id
}