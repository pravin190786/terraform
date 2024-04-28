resource "aws_subnet" "public_subnets" {
  count             = length(keys(var.public_subnets))
  vpc_id            = aws_vpc.this.id
  cidr_block        = values(var.public_subnets)[count.index]
  availability_zone = element(keys(var.public_subnets), count.index)
  tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-public-sub-${var.env}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(keys(var.private_subnets))
  vpc_id            = aws_vpc.this.id
  cidr_block        = values(var.private_subnets)[count.index]
  availability_zone = element(keys(var.private_subnets), count.index)

    tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-private-sub-${var.env}"
  }

}