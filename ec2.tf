
# resource "aws_network_interface" "Deploy9_NI" {
#   subnet_id   = aws_subnet.Private.id
#   security_groups  = [aws_security_group.allow_80.id]
#   tags = {
#     Name = "primary_network_interface"
#     }
# }

# resource "aws_security_group" "allow_80_EC2" {
#   name        = "allow_80_EC2"
#   description = "allow port 80 inbound traffic for ec2"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     security_groups  = [aws_security_group.allow_80.id]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_80"
#   }
# }

# resource "aws_instance" "ec2" {
#   ami           = "ami-08dfbc89f2b92f657"
#   instance_type = "t2.micro"
#   network_interface {
#       network_interface_id = aws_network_interface.Deploy9_NI.id
#       device_index         = 0
#       }
#   tags = {
#     Name = "Deploy9_EC2"
#   }
# }