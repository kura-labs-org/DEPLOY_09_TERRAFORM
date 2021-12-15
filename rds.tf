resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "TLS from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ubuntu_ec2.id]
  }
  tags = {
    Name = "SG-for-RDS"
  }
}


resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  engine                 = "postgresql"
  engine_version         = "9.6.20-R1"
  instance_class         = "db.t2.micro"
  multi_az               = "true"
  name                   = "mydb"
  username               = "bishajit"
  password               = "kura123"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.internal01.id, aws_subnet.internal02.id]

  tags = {
    Name = "My DB subnet group"
  }
}