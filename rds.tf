resource "aws_db_instance" "database" {
  multi_az       = true
  instance_class = "db.t3.micro"
  name           = "deploy09"
  username       = "admin"
  password       = "abc123abc"

  allocated_storage   = 10
  engine              = "mysql"
  engine_version      = "5.7"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.id
  tags = {
    "Name" = "deploy09_database"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow traffic from ec2 to rds database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow traffic from EC2 Security Group"
    protocol        = "TCP"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tags = {
    Name = "allow_ALB"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "mysql_interals"
  subnet_ids = [aws_subnet.internal01.id, aws_subnet.internal02.id]

  tags = {
    Name = "deploy09_database_subnet_group"
  }
}
