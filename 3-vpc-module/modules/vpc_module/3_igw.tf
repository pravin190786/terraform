resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-igw-${var.env}"
  }
}