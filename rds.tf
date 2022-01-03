# resource "aws_db_instance" "deploy9db" {
#   allocated_storage      = 10
#   engine                 = "postgres"
#   engine_version         = "9.6"
#   instance_class         = "db.t2.micro"
#   name                   = "Deploy9db"
#   multi_az               = true
#   username               = "Juan"
#   password               = "DaDBPassword"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.database-sg.id]
#   db_subnet_group_name   = aws_db_subnet_group.internals-db.id
# }


# resource "aws_security_group" "database-sg" {
#   name        = "deploy9-db-sg"
#   description = "Take traffic from ec2"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description     = "HTTP from EC2"
#     from_port       = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.allow_80_EC2.id]
#     to_port         = 5432
#   }

#   tags = {
#     "Name" = "deployment 9 security group for database "
#   }
# }

# resource "aws_db_subnet_group" "internals-db" {
#   name       = "internals-db"
#   subnet_ids = [aws_subnet.Internal01.id, aws_subnet.Internal02.id]

#   tags = {
#     Name = "DB-subnet-group"
#   }
# }