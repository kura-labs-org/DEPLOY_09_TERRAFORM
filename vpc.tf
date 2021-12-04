# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

#Configure Subnets
resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public01 Subnet"
  }
}

resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public02 Subnet"
  }
}

resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private01 Subnet"
  }
}

resource "aws_subnet" "int-sub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Internal Subnet 1"
  }
}
resource "aws_subnet" "int-sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Internal Subnet 2"
  }
}

#Internet Gateway Configuration
resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main - Internet Gateway"
  }
}

#Elastic IP Configuration
resource "aws_eip" "elb" {
  vpc = true

  tags = {
    Name = "Nat Gateway EIP"
  }
}


#Nat Gateway Configuration
resource "aws_nat_gateway" "pnat" {
  allocation_id = aws_eip.elb.id
  connectivity_type = "public"
  subnet_id = aws_subnet.public01.id

  tags = {
    Name = "Nat Gateway"
  }
}

#Routing table configuration
resource "aws_route_table" "public-table" {
  vpc_id = aws_vpc.main.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.ig1.id
   }

   tags = {
     Name = "Main Public Routing Table"
   }
 }

 resource "aws_route_table" "private-table" {
   vpc_id = aws_vpc.main.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.pnat.id
   }

   tags = {
     Name = "Main Private Routing Table"
   }
 }

