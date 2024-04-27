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
    key     = "2-simple-web-app/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

# aws provider & profile while executing the terraform
provider "aws" {
  region  = "ap-south-1"
  profile = "pravin-aws"
}

## create an web app ec2 01
resource "aws_instance" "web_server_01" {
  ami             = "ami-0f58b397bc5c1f2e8"
  instance_type   = "t2.micro"
  user_data       = <<-EOF
            #!/bin/bash
              sudo apt update
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<html><head><title>Sample Page</title></head><body><h1>Hello, World!</h1><p>This is a sample HTML page.web_server_01</p></body></html>" | sudo tee /var/www/html/index.html
            EOF
  key_name        = "git-hub-runner"
  security_groups = [aws_security_group.web_server_sg.id]
  tags = {
    Name      = "web_server_01"
    CreatedBy = "TF"
  }
  subnet_id = data.aws_subnet.default_subnet_2.id
}

## create an web app ec2 01
resource "aws_instance" "web_server_02" {
  ami             = "ami-0f58b397bc5c1f2e8"
  instance_type   = "t2.micro"
  user_data       = <<-EOF
            #!/bin/bash
              sudo apt update
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<html><head><title>Sample Page</title></head><body><h1>Hello, World!</h1><p>This is a sample HTML page. web_server_02</p></body></html>" | sudo tee /var/www/html/index.html
            EOF
  key_name        = "git-hub-runner"
  security_groups = [aws_security_group.web_server_sg.id]
  tags = {
    Name      = "web_server_02"
    CreatedBy = "TF"
  }
  subnet_id = data.aws_subnet.default_subnet_1.id
}

## use default VPC 172.31.0.0/16
data "aws_vpc" "default_vpc" {
  default = true
}

# Retrieve the default subnet ID
data "aws_subnet" "default_subnet_1" {
  vpc_id            = data.aws_vpc.default_vpc.id
  availability_zone = "ap-south-1a"
  default_for_az    = true
}
data "aws_subnet" "default_subnet_2" {
  vpc_id            = data.aws_vpc.default_vpc.id
  availability_zone = "ap-south-1b"
  default_for_az    = true
}

## EC2 security groups
resource "aws_security_group" "web_server_sg" {
  name = "web_server_sg"
}

resource "aws_security_group_rule" "web_server_allow_rule" {

  type              = "ingress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "ssh_allow_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["106.213.81.254/32"]
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## ALB Security groups ingress & egress
resource "aws_security_group" "alb_web_sg" {
  name = "alb_web_sg"
}
resource "aws_security_group_rule" "alb_web_allow_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_web_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "alb_web_allow_outbound_rule" {
  type              = "egress"
  security_group_id = aws_security_group.alb_web_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## Create ALB 
resource "aws_alb" "alb_web_app" {
  name               = "alb-web-app"
  load_balancer_type = "application"
  subnets = [
    data.aws_subnet.default_subnet_1.id,
    data.aws_subnet.default_subnet_2.id
  ]
  security_groups = [aws_security_group.alb_web_sg.id]
}

## Add ALB listerener and deafult action to 404
resource "aws_alb_listener" "alb_http_listener" {
  load_balancer_arn = aws_alb.alb_web_app.arn
  port              = 80

  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 : page not found"
      status_code  = 404
    }
  }
}

## Create a target Group/TG
resource "aws_alb_target_group" "tg_alb_web_app" {
  name     = "tg-alb-web-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

## Attach EC2 instances to TG

resource "aws_alb_target_group_attachment" "attach_web_server_01" {
  target_group_arn = aws_alb_target_group.tg_alb_web_app.arn
  target_id        = aws_instance.web_server_01.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "attach_web_server_02" {
  target_group_arn = aws_alb_target_group.tg_alb_web_app.arn
  target_id        = aws_instance.web_server_02.id
  port             = 80
}

## create ALB Listener Rule

resource "aws_alb_listener_rule" "alb_web_app_rule" {
  listener_arn = aws_alb_listener.alb_http_listener.arn 
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg_alb_web_app.arn
  }
}

resource "aws_route53_record" "alb_route53_record" {
  zone_id = "Z0347645R4KWJGRA7YYJ"
  name    = "alb.p3ktek.com"
  type    = "A"
  alias {
    name                   = aws_alb.alb_web_app.dns_name
    zone_id                = aws_alb.alb_web_app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_db_instance" "web_app_db" {
  allocated_storage          = 5
  auto_minor_version_upgrade = true
  storage_type               = "standard"
  engine                     = "postgres"
  engine_version             = "16.1"
  instance_class             = "db.t3.micro"
  license_model              = "postgresql-license"
  username                   = "root"
  password                   = "root1234"
  skip_final_snapshot        = true
}

resource "aws_s3_bucket" "samples3bucket" {
  bucket = "p3ktek.com.sample"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}