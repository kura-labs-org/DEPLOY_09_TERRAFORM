# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

# 1. Creating a VPC

# CIDR block - 10.0.0.0/1
# Subnet mask 255.255.255.255
# Network portion = 18
# Host portion = 14
# 2^14 =  16384 ips

# Subnetting the VPC

# Public subnet 1
# The range is 

#vpc
#	10.0.0.0/18
#	network portion 18
#	host portion 14
# 2^14 = 16,384

# subnetting

# public1
# 10.0.0.0/24   range 0-255
# network portion 24
# host portion 8
# ips 256

# puclic2
# 10.0.1.0/24
# network portion 24
# host portion 8
# ips 256

# private1
# 10.0.2.0/24
# network portion 24
# host portion 8
# ips 256

# internal
# 10.0.3.0/24
# network portion 24
# host portion 8
# ips 256

# internal2
# 10.0.4.0/24
# netwokr portion 24
#	host portion 8
#	ips 256




#Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/18"
  tags = {
    Name = "Main VPC"
  }
}

#Creating public subnet 1
resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "public01"
  }
}

#Creating public subnet 2
resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "public02"
  }
}
#Creating private subnet 1
resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "private01"
  }
}
#Creating internal subnet 1
resource "aws_subnet" "internal01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "internal01"
  }
}
#Creating internal subnet 2
resource "aws_subnet" "internal02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "internal02"
  }
}

#Creating Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet gateway"
  }
}

#Route Table for public subnets
resource "aws_route_table" "routetable_pb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Route Table for public subnet"
  }
}
#Route Table for private subnet
resource "aws_route_table" "routetable_pv" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway.id
  }

  tags = {
    Name = "Route Table for private subnet"
  }
}
#Elastic IP for NAT Gateway
resource "aws_eip" "elasticip" {
  vpc      = true
}

#Create in NAT gateway to go in public subnet 
resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}

#Route table association for Public subnet 1
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.routetable_pb.id
}

#Route table association for Public subnet 2
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.routetable_pb.id
}

#Route table association for Private subnet 1
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.routetable_pv.id
}

#EC2

resource "aws_instance" "instance01" {
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"
  availability_zone = "us-east-2a" 
  subnet_id = aws_subnet.private01.id
  vpc_security_group_ids = []
  tags = {
    Name = "private_ec2"
  }
}
