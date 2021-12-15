# 1VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

#public1
resource "aws_subnet" "public01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public01"
  }
}

#public2
resource "aws_subnet" "public02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public02"
  }
}

#Private1 
resource "aws_subnet" "private01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "Private01"
  }
}

#Internal1
resource "aws_subnet" "internal01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "Internal01"
  }
}

#Internal2
resource "aws_subnet" "internal02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "Internal02"
  }
}




#2. create internet gatewat
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig1"
  }
}

resource "aws_eip" "nat1" {
  # EIP may require IGW to exist prior to association. 
  # Use depends_on to set an explicit dependency on the IGW.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat2" {
  # EIP may require IGW to exist prior to association. 
  # Use depends_on to set an explicit dependency on the IGW.
  depends_on = [aws_internet_gateway.main]
}

#3. Create a public Nat gateways for private subbnet, created 2 for the failoever
resource "aws_nat_gateway" "gw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public01.id #public subnet

  tags = {
    Name = "public NAT"
  }
}

resource "aws_nat_gateway" "gw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public02.id #public subnet

  tags = {
    Name = "public NAT2"
  }


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


# 4. Create  Route Tables

#main route table/public route table
resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    "Name" = "main-route-table"
  }
}


resource "aws_route_table" "private-rt-01" {
  # The VPC ID.
  vpc_id = aws_vpc.main.id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC NAT gateway.
    nat_gateway_id = aws_nat_gateway.gw1.id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "private-1"
  }
}

# 5. Create  Route Tables associations
resource "aws_route_table_association" "public1" {
  subnet_id = aws_subnet.public01.id
  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.main-route-table.id
}

resource "aws_route_table_association" "public2" {
  subnet_id = aws_subnet.public02.id
  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.main-route-table.id
}

resource "aws_route_table_association" "private1" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.private01.id

  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.private-rt-01.id
}


 