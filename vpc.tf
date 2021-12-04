# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

### Subnets

resource "aws_subnet" "public01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public02"
  }
}

resource "aws_subnet" "private01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private01"
  }
}

#### Internal Subnets
resource "aws_subnet" "internal01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Internal01"
  }
}

resource "aws_subnet" "internal02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Internal02"
  }
}


### Internet Gateway

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig1"
  }
}

### Nat Gateway

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id = aws_subnet.public01.id


  
}

#### Elastic IP for Nat Gateway

resource "aws_eip" "nat_elastic_ip" {
  vpc = true
}

### Route Table

# Public RT
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig1.id
  }

  tags = {
    "Name" = "main-vpc-table"
  }
}

# Private RT
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    "Name" = "Private Route Table for Deploy9"
  }
}

### Configuring route table for public

resource "aws_route_table_association" "main_vpc_public01_subnet_route" {
    subnet_id = aws_subnet.public01.id
    route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "main_vpc_public02_subnet_route" {
    subnet_id = aws_subnet.public02.id
    route_table_id = aws_route_table.public-route-table.id
}

### Configuring route table for private

resource "aws_route_table_association" "main_vpc_private01_subnet_route" {
    subnet_id = aws_subnet.private01.id
    route_table_id = aws_route_table.private-route-table.id
}