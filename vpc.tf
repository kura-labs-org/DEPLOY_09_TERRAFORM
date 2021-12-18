# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

#1. Create VPC
#CIDR - VPC
#10.0.0.0/24
#255.255.255.255
#Network portion - 24
#Host portion - 8 --256ips

#Break VPC into 8 subnets

#public01 (32)
# 10.0.0.0/27  range 0-31
# Network portion - 27
# Host portion - 5 --32ips

#public02 (32)
# 10.0.0.32/27  range 32-63
# Network portion - 27
# Host portion - 5 --32ips

#private01 (32)
# 10.0.0.64/27  range 64-95
# Network portion - 27
# Host portion - 5 --32ips

#internal01 (32)
# 10.0.0.96/27  range 96-127
# Network portion - 27
# Host portion - 5 --32ips

#internal02 (32)
# 10.0.0.128/27  range 128-159
# Network portion - 27
# Host portion - 5 --32ips

#1. Create VPC
resource "aws_vpc" "deploy9-vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "deploy9-vpc"
  }
}

#2. Create Internet Gateway
resource "aws_internet_gateway" "deploy9-ig" {
  vpc_id = aws_vpc.deploy9-vpc.id

  tags = {
    Name = "deploy9-ig"
  }
}

#3. Create public subnet 1
resource "aws_subnet" "deploy9-public01-subnet" {
  vpc_id     = aws_vpc.deploy9-vpc.id
  cidr_block = "10.0.0.0/27"
  availability_zone = "us-east-1a"
  tags = {
    Name = "deploy9-public01-subnet"
  }
}

#4. Create public subnet 2
resource "aws_subnet" "deploy9-public02-subnet" {
  vpc_id     = aws_vpc.deploy9-vpc.id
  cidr_block = "10.0.0.32/27"
  availability_zone = "us-east-1b"
  tags = {
    Name = "deploy9-public02-subnet"
  }
}

#5. Create private subnet 1
resource "aws_subnet" "deploy9-private01" {
  vpc_id     = aws_vpc.deploy9-vpc.id
  cidr_block = "10.0.0.64/27"
  availability_zone = "us-east-1a"
  tags = {
    Name = "deploy9-private01"
  }
} 

#6. Create Custom Route Table for public subnets
resource "aws_route_table" "deploy9-public-route-table" {
  vpc_id = aws_vpc.deploy9-vpc.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.deploy9-ig.id
  }

  tags = {
    "Name" = "deploy9-public-route-table"
  }
}

#7. Create Custom Route Table for private subnet
resource "aws_route_table" "deploy9-private-route-table" {
  vpc_id = aws_vpc.deploy9-vpc.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.deploy9-nat.id
  }

  tags = {
    "Name" = "deploy9-private-route-table"
  }
}

#8. Associate public01 Subnet with public Route Table
resource "aws_route_table_association" "deploy9-sub-rt-public01" {
  subnet_id = aws_subnet.deploy9-public01-subnet.id
  route_table_id = aws_route_table.deploy9-public-route-table.id
}

#9. Associate public02 Subnet with public Route Table
resource "aws_route_table_association" "deploy9-sub-rt-public02" {
  subnet_id = aws_subnet.deploy9-public02-subnet.id
  route_table_id = aws_route_table.deploy9-public-route-table.id
}

#10. Associate private01 Subnet with private Route Table
resource "aws_route_table_association" "deploy9-sub-rt-private01" {
  subnet_id = aws_subnet.deploy9-private01.id
  route_table_id = aws_route_table.deploy9-private-route-table.id
}

#11. Allocate Elastic IP to NAT Gateway
resource "aws_eip" "deploy9-eip" {
  vpc      = true
  depends_on = [aws_internet_gateway.deploy9-ig]
}

#12. Create NAT Gateway
resource "aws_nat_gateway" "deploy9-nat" {
  allocation_id = aws_eip.deploy9-eip.id
  subnet_id     = aws_subnet.deploy9-public01-subnet.id

  tags = {
    Name = "deploy9-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}

#13. Create Ubuntu instance in private subnet
resource "aws_instance" "deploy9-private-instance" {
  ami = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  subnet_id = aws_subnet.deploy9-private01.id
  vpc_security_group_ids = [aws_security_group.deploy9-private-security-group.id]
  key_name = "terra-key"

  tags = {
    "Name" = "deploy9-private-instance"
  }
}

#14. Create Security Group for private instance to allow port 80
resource "aws_security_group" "deploy9-private-security-group" {
  name = "deploy9-web-traffic"
  description = "Allow web traffic"
  vpc_id = aws_vpc.deploy9-vpc.id

  # ingress {
  #   cidr_blocks = [ "10.0.0.64/27" ]
  #   description = "HTTP"
  #   from_port = 80
  #   protocol = "tcp"
  #   security_groups = [aws_security_group.deploy9-alb-security-group.id]
  #   self = false
  #   to_port = 80
  # } 

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "All exit"
    from_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
    to_port = 0
  } ]

  tags = {
    "Name" = "deploy9-allow-web-traffic"
  }

}

#15. Creating 1 application load balancer in the 2 public subnets
resource "aws_lb" "deploy9-alb" {
  name               = "deploy9-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.deploy9-alb-security-group.id]
  subnets            = [aws_subnet.deploy9-public01-subnet.id, aws_subnet.deploy9-public02-subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "deploy9-alb"
  }
}

#16. Create Security Group for ALB to allow port 80
resource "aws_security_group" "deploy9-alb-security-group" {
  name = "deploy9-alb-security-group"
  description = "Allow http traffic on alb"
  vpc_id = aws_vpc.deploy9-vpc.id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP"
    from_port = 80
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 80
  } 

  # egress = [ {
  #   cidr_blocks = [ "10.0.0.64/27" ]
  #   description = "private instance security group"
  #   from_port = 0
  #   protocol = "-1"
  #   ipv6_cidr_blocks = ["::/0"]
  #   prefix_list_ids = []
  #   security_groups = [aws_security_group.deploy9-private-security-group.id]
  #   self = false
  #   to_port = 0
  # } ]

  tags = {
    "Name" = "deploy9-alb-security-group"
  }

} 

#17. Create a target group 
resource "aws_lb_target_group" "deploy9-target-group" {
  name     = "deploy9-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.deploy9-vpc.id
}

#18. Attach private instance to target group
resource "aws_lb_target_group_attachment" "deploy9-target-group-attachment" {
  target_group_arn = aws_lb_target_group.deploy9-target-group.arn
  target_id        = aws_instance.deploy9-private-instance.id
  port             = 80
}

#19. Application load balancer listener to forward traffic to target group
resource "aws_lb_listener" "deploy9-alb-listener" {
  load_balancer_arn = aws_lb.deploy9-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.deploy9-target-group.arn
  }
}

#20. Create postgressql rds instance
resource "aws_db_instance" "deploy9-db" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  name                 = "deploy9_db"
  username             = "deploy9"
  password             = "deploy9-pw"
  db_subnet_group_name = aws_db_subnet_group.deploy9-internal-subnet-group.id
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.deploy9-db-security-group.id]

  # tags {
  #   Name = "deploy9-db"
  # }
}

#21. Create Security Group for database instance to allow port 80
resource "aws_security_group" "deploy9-db-security-group" {
  name = "deploy9-db-security-group"
  description = "Allow http traffic on db fromprivate instance security group"
  vpc_id = aws_vpc.deploy9-vpc.id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP"
    from_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.deploy9-private-security-group.id]
    self = false
    to_port = 80
  } 

  egress = [ {
    cidr_blocks = [ "10.0.0.64/27" ]
    description = "db instance security group"
    from_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = [aws_security_group.deploy9-private-security-group.id]
    self = false
    to_port = 0
  } ]

  tags = {
    "Name" = "deploy9-db-security-group"
  }

} 

#22. 

#FIXES
#Creating ingress security group rule for deploy9-private-security group
resource "aws_security_group_rule" "deploy9-rule-private-sg" {
  type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.deploy9-private-security-group.id
    source_security_group_id = aws_security_group.deploy9-alb-security-group.id
}

#Creating egress security group rule for deploy9-alb-security group
resource "aws_security_group_rule" "deploy9-rule-alb-sg" {
  type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.deploy9-alb-security-group.id
    source_security_group_id = aws_security_group.deploy9-private-security-group.id
}

#Create internal subnet 1
resource "aws_subnet" "deploy9-internal01" {
  vpc_id     = aws_vpc.deploy9-vpc.id
  cidr_block = "10.0.0.96/27"
  availability_zone = "us-east-1a"
  tags = {
    Name = "deploy9-internal01"
  }
}

#Create internal subnet 2
resource "aws_subnet" "deploy9-internal02" {
  vpc_id     = aws_vpc.deploy9-vpc.id
  cidr_block = "10.0.0.128/27"
  availability_zone = "us-east-1b"
  tags = {
    Name = "deploy9-internal02"
  }
}

#Create subnet group for internal subnets
resource "aws_db_subnet_group" "deploy9-internal-subnet-group" {
  name       = "deploy9-internal-subnet-group"
  subnet_ids = [aws_subnet.deploy9-internal01.id, aws_subnet.deploy9-internal02.id]

  tags = {
    Name = "deploy9-internal-subnet-group"
  }
}