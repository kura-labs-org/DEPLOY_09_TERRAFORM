resource "aws_security_group" "db_SG" {
  name        = "db_SG"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.allow_tcp.id]
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "saidb"

  engine            = "mysql"
  instance_class    = "db.t2.large"
  allocated_storage = 5

  name                                = "example_db"
  username                            = "user"
  password                            = "YourPwdShouldBeLongAndSecure!"
  port                                = "3306"
  multi_az                            = true
  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db_SG.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = [aws_subnet.internal01.id, aws_subnet.internal02.id]

  # Database Deletion Protection
  deletion_protection = false
}