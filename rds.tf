resource "aws_security_group" "database-sg" {
  name        = "deployment09-db-sg"
  description = "Take traffic from ubuntu ec2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from EC2"
    from_port       = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ubuntu_ec2.id]
    to_port         = 5432
  }

  tags = {
    "Name" = "deployment9 database security group"
  }
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_group_for_postgres"
  subnet_ids = [aws_subnet.internal01.id, aws_subnet.internal02.id]

  tags = {
    Name = "Subnet group for postgres"
  }

}


resource "aws_db_instance" "postgres_db" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "9.6"
  instance_class         = "db.t2.micro"
  name                   = "database_for_deploy9"
  username               = "zac"
  multi_az               = true
  password               = "best_db_ever"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database-sg.id]
}
