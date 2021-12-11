# 2 route tables (public & private)
# public
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    "Name" = "public-route-table"
  }
}

# Associate Public Route Table to 
# Public Subnet = Public01
resource "aws_route_table_association" "pubrtable1" {
subnet_id = aws_subnet.public01.id
route_table_id = aws_route_table.public-route-table.id

}

# Associate Public Route Table to 
# Public Subnet = Public02
resource "aws_route_table_association" "pubrtable2" {
subnet_id = aws_subnet.public02.id
route_table_id = aws_route_table.public-route-table.id
}
 

# Private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT.id
    }
    tags = {
      "Name" = "prvt-rt-tbl"
    }
}

# Associate Private Route Table to 
# Private Subnet = Private01
resource "aws_route_table_association" "prvtrtable1" {
  subnet_id = aws_subnet.private01.id
  route_table_id = aws_route_table.private-route-table.id

}
