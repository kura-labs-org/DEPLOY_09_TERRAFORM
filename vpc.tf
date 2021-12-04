# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}


resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public1"
  map_public_ip_on_launch = true
  }
}
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public2"
  map_public_ip_on_launch = true
  }
}
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.32.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private1"
  }
}
resource "aws_subnet" "internal1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.48.0/21"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Internal1"
  }
}
resource "aws_subnet" "internal2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.56.0/21"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Internal2"
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "KuraIG"
    
  }
}

resource "aws_route_table" "routetable1" {
  vpc_id = aws_vpc.main.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig1.id
  }

  tags = {
    "Name" = "RouteTable1"
  }
}
resource "aws_route_table" "routetable2" {
  vpc_id = aws_vpc.main.id
  route = []
  tags = {
    "Name" = "RouteTable2"
  }
}

resource "aws_nat_gateway" "natg1" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private1.id

    tags = {
    Name = "Private NAT"
  }
}

resource "aws_route_table_association" "publicroute1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.routetable1.id
}


resource "aws_route_table_association" "publicroute2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.routetable1.id
}

resource "aws_route_table_association" "privateroute1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.routetable2.id
}