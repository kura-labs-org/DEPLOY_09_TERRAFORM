# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

# creating VPC "Main"
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public02"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "deploy9_igw1"
  }
}

resource "aws_route_table" "route-table-pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "deploy09_rt_pub"
  }
}

resource "aws_route_table" "route-table-priv" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "deploy09_rt_priv"
  }
}

resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private01"
  }
}

resource "aws_subnet" "internal01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Internal01"
  }
}

resource "aws_subnet" "internal02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Internal02"
  }
}

resource "aws_eip" "elastic_ip" {
  vpc = true
}

resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "deploy9_NATgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#Creating EC2 and Security Group
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "EC2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id  = aws_subnet.private01.id

  tags = {
    Name = "deploy9_EC2"
  }
}

resource "aws_security_group" "allow_alb" {
  name        = "ec2_traffic"
  description = "Allow port 80 traffic from the ALB security group and any traffic outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow port 80 traffic from the ALB security group"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "priv01_EC2_sg"
  }
}


resource "aws_security_group" "alb" {
  name        = "alb_sg"
  description = "Allow port 80 traffic from the ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.allow_alb.id]
  }

  tags = {
    Name = "alb_sg"
  }
}