# Create subnets in each (internal) AZ for RDS
resource "aws_subnet" "rds1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  
    tags = {
      "Name" = "rds-internal"
    }
  
}

# Create a subnet group for RDS  
# The group will be applied to the DB instance 
resource "aws_db_subnet_group" "db_sg1" {
  name        = "rds_sg1"
  description = "RDS is in first internal subnet groups in 1a"
  subnet_ids  = [aws_subnet.internal01.id, aws_subnet.internal02.id]
}

# Create a RDS security group in the VPC 
# where the DB belongs.

resource "aws_security_group" "rds1" {
  name        = "rds_security_group"
  description = "RDS MySQL server"
  vpc_id      = aws_vpc.main.id
  
  # Keep the instance private.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.tfec2-sg.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
      "Name" = "rds-security-group-1"
    }
  
}

# Create a RDS MySQL database instance 
# in the VPC with our RDS subnet group and security group:

resource "aws_db_instance" "dbsg1" {
  allocated_storage         = 10
  engine                    = "mysql"
  engine_version            = "8.0.23"
  instance_class            = "db.t2.micro"
  name                      = "rdsdatabse1"
  username                  = "kurards1"
  password                  = "kuralabs2021"
  port                      = 3306
  multi_az                  = true
  db_subnet_group_name      = "${aws_db_subnet_group.db_sg1.id}"
  vpc_security_group_ids    = ["${aws_security_group.rds1.id}"]
  skip_final_snapshot       = true
}

# MySQL configuration 

resource "aws_db_parameter_group" "db_sg1" {
  name        = "rds"
  description = "parameter group for mysql5.6"
  family      = "mysql8.0"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}