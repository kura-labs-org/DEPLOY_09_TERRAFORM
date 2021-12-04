resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  multi_az             = true
  name                 = "mydb"
  username             = var.user
  password             = var.pass
  skip_final_snapshot  = true
}