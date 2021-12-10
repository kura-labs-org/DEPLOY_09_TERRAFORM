# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public01"
  }
}

resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public02"
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ig1"
  }
}

resource "aws_route_table" "test-route-table" {
  vpc_id = aws_vpc.main.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig1.id
  }

  tags = {
    "Name" = "tf-route-table-test"
  }
}

resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.test-route-table.id
}

resource "aws_route_table_association" "public02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.test-route-table.id
}




resource "aws_eip" "tf-eip" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-gw1" {
  allocation_id = aws_eip.tf-eip.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "tf-nat"
  }
  depends_on = [aws_internet_gateway.ig1]
}


resource "aws_route_table" "tf-private-route-table" {
  vpc_id = aws_vpc.main.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat-gw1.id
  }

  tags = {
    "Name" = "tf-private-route-table"
  }
}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.tf-private-route-table.id
}


# ALB Security Group
resource "aws_security_group" "ALB-sg" {
  name = "alb-security-group"
  description = "Allow web traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP"
    from_port = 80
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 80
  } 

  tags = {
    "Name" = "ALB-sg"
  }
}

# Create EC2 Security Group
resource "aws_security_group" "priv_ec2" {
  name = "project1-web-traffic"
  description = "Allow traffic from ALB only"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from ALB"
    from_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.ALB-sg.id]
    self = false
    to_port = 80
  } 
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "priv_ec2_sg"
  }
}

resource "aws_security_group_rule" "alb-egress" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ALB-sg.id
  source_security_group_id = aws_security_group.priv_ec2.id
}


# CREATE EC2    
resource "aws_instance" "EC2" {
  ami           = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private01.id
  vpc_security_group_ids = [aws_security_group.priv_ec2.id]

  tags = {
    Name = "App EC2"
  }
}

# Create ALB

# resource "aws_lb" "ALB" {
#   name               = "ALB"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = aws_subnet.public01.id

#   enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

#   tags = {
#     Environment = "production"
#   }
# }