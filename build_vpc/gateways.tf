#  Internet Gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "igw1"
  }
}

#Elastic IP for NAT Gateway resource
resource "aws_eip" "EIP" {
  vpc = true
  tags = {
    Name = "aws_eip" 
    }
  }

# Creating a NAT Gateway
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.private01.id

  tags = {
    Name = "ngw"
  }

  # To ensure proper ordering, it is recommended 
  # to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw1]
}