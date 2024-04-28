resource "aws_eip" "this" {
  domain = "vpc"
  tags = {
    Env     = "${var.env}"
    Name = "${var.app_name}-eip-${var.env}"
  }
}
