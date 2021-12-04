# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

# Create 2 public subnets
resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "public01"
  }
}


resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "public02"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig1"
  }
}

# 3. Create Custom Route Table
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


