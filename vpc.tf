#Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "deploy09_vpc"
  }
}
#Create 2 public subnets, 2 private subnets, 2 interal subnets
resource "aws_subnet" "public01" {
  vpc_id = aws_vpc.main.id

  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "deploy09_public01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id = aws_vpc.main.id

  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "deploy09_public02"
  }
}

resource "aws_subnet" "private01" {
  vpc_id = aws_vpc.main.id

  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "deploy09_private01"
  }
}

resource "aws_subnet" "private02" {
  vpc_id = aws_vpc.main.id

  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "deploy09_private02"
  }
}

resource "aws_subnet" "internal01" {
  vpc_id = aws_vpc.main.id

  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "deploy09_internal01"
  }
}

resource "aws_subnet" "internal02" {
  vpc_id = aws_vpc.main.id

  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "deploy09_internal02"
  }
}


#Create Public and Private Route Table
resource "aws_route_table" "routetable_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "deploy09_routetable_public"
  }
}

resource "aws_route_table" "routetable_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    "Name" = "deploy09_routetable_private"
  }
}

#Create Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "deploy09_igw"
  }
}

# Elastic IP for Nat Gateway
resource "aws_eip" "nat_elastic_ip" {
  vpc = true
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_private" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id         = aws_subnet.private01.id
}


