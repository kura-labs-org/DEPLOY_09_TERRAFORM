# Creating the EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.network_interface.id
    device_index         = 0 #first attached network interface
  }
  tags = {
    Name = "EC2 Instance"
  }
}

#Creating the EC2 Security Group that allows port 80 from ALB
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "allow port 80 access for alb"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow port 80 traffic from alb_SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "EC2 Security Group"
  }
}


#Creating the network interface
resource "aws_network_interface" "network_interface" {
  subnet_id       = aws_subnet.private01.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Network Interface"
  }
}
