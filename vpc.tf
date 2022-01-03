# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

# #Creates Public Subnet 
# resource "aws_subnet" "Public01" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-1a"
#   tags = {
#     Name = "Public01"
#   map_public_ip_on_launch = true
#   }
# }
# #Creates Public Subnet 2
# resource "aws_subnet" "Public02" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "us-east-1b"
#   tags = {
#     Name = "Public02"
#   map_public_ip_on_launch = true
#   }
# }
# #Creates Private Subnet
# resource "aws_subnet" "Private" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.3.0/24"
#   availability_zone = "us-east-1a"
#   tags = {
#     Name = "Private"
#   }
# }
# #Creates Internal Subnet 1
# resource "aws_subnet" "Internal01" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.4.0/24"
#   availability_zone = "us-east-1a"
#   tags = {
#     Name = "Internal01"
#   }
# }
# #Creates Internal Subnet 2
# resource "aws_subnet" "Internal02" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.5.0/24"
#   availability_zone = "us-east-1b"
#   tags = {
#     Name = "Internal02"
#   }
# }
# #Creates Internet Gateway Subnet
# resource "aws_internet_gateway" "ig1" {
#   vpc_id = aws_vpc.main.id
  
#   tags = {
#     Name = "Deploy09-IG"
    
#   }
# }
# #Creates "Public" Route Table 
# resource "aws_route_table" "Public_RouteTable" {
#   vpc_id = aws_vpc.main.id

#   route {
#   cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.ig1.id
#   }

#   tags = {
#     "Name" = "Public_RouteTable"
#   }
# }
# #Creates "Private" Route Table 
# resource "aws_route_table" "Private_RouteTable" {
#   vpc_id = aws_vpc.main.id
#   route = []
#   tags = {
#     "Name" = "Private_RouteTable"
#   }
# }
# #Create Route Table For Public Subnets
# resource "aws_nat_gateway" "natg1" {
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.Private.id

#     tags = {
#     Name = "Private NAT"
#   }
# }
# #Associates "Public" Route Table to Public Subnet 1
# resource "aws_route_table_association" "Publicroute1" {
#   subnet_id      = aws_subnet.Public01.id
#   route_table_id = aws_route_table.Public_RouteTable.id
# }

# #Associates "Public" Route Table to Public Subnet 2
# resource "aws_route_table_association" "Publicroute2" {
#   subnet_id      = aws_subnet.Public02.id
#   route_table_id = aws_route_table.Public_RouteTable.id
# }
# #Associates "Private" Route Table to Private Subnet
# resource "aws_route_table_association" "Privateroute1" {
#   subnet_id      = aws_subnet.Private.id
#   route_table_id = aws_route_table.Private_RouteTable.id 
# }