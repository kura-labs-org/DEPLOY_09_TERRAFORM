# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public02"
  }
}

resource "aws_subnet" "Private01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "Private01"
  }
}

resource "aws_subnet" "internal01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "internal01"
  }
}

resource "aws_subnet" "internal02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "internal02"
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "InternetGateway1"
  }
}

resource "aws_route_table" "project1-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig1.id
  }

  tags = {
    "Name" = "project1-route-table"
  }
}

resource "aws_security_group" "allow_tcp" {
  name        = "allow_tcp"
  description = "Allow TCP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp"
  }
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = "single-instance"
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.micro"
  key_name               = "saikey"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_tcp.id]
  subnet_id              = aws_subnet.Private01.id
  tags = {
    Name        = "single-instance"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "Ec2-TG" {
  name     = "Ec2-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.Ec2-TG.arn
  target_id        = module.ec2_instance.id
  port             = 80
}

resource "aws_security_group" "lb_SG" {
  name        = "lb_SG"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.allow_tcp.id]
  }

  tags = {
    Name = "lb_SG"
  }
}

resource "aws_lb" "deploy9_lb" {
  name                       = "deploy9-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_SG.id]
  subnets                    = [aws_subnet.public01.id, aws_subnet.public02.id]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_security_group" "db_SG" {
  name        = "db_SG"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.allow_tcp.id]
  }
}

  module "db" {
    source  = "terraform-aws-modules/rds/aws"
    version = "~> 3.0"

    identifier = "saidb"

    engine            = "mysql"
    instance_class    = "db.t2.large"
    allocated_storage = 5

    name     = "example_db"
    username = "user"
    password = "YourPwdShouldBeLongAndSecure!"
    port     = "3306"
    multi_az = true
    iam_database_authentication_enabled = true

    vpc_security_group_ids = [aws_security_group.db_SG.id]

    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_window      = "03:00-06:00"

    tags = {
      Owner       = "user"
      Environment = "dev"
    }

    # DB subnet group
    subnet_ids = [aws_subnet.internal01.id, aws_subnet.internal02.id]

    # Database Deletion Protection
    deletion_protection = false
  }


