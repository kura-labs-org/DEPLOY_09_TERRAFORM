resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  multi_az             = true
  name                 = "mydb"
  username             = var.user
  password             = var.pass
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.EC2toDB.id]
  db_subnet_group_name   = aws_db_subnet_group.dbinternals.id
}

resource "aws_db_subnet_group" "dbinternals" {
  name       = "postgresinternals"
  subnet_ids = [aws_subnet.internal1.id, aws_subnet.internal2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "EC2toDB" {
  name        = "DBtoEC"
  description = "Allows Traffic from EC to DB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.allow_80.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ALB"
  }
}