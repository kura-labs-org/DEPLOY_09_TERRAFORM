#RDS Database Configuration
resource "aws_db_instance" "rds1" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  multi_az             = true
  name                 = "mydb"
  username             = var.admin_username
  password             = var.admin_password
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.RDS-SG.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-internal-subs.id
}


#RDS Database Subnet Configuration
resource "aws_db_subnet_group" "rds-internal-subs" {
  name       = "rds-internal-subs"
  subnet_ids = [aws_subnet.int-sub1.id, aws_subnet.int-sub2.id]

  tags = {
    Name = "RDS Database Subnet Group"
  }
}