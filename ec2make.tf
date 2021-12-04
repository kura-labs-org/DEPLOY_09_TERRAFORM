resource "aws_network_interface" "nic1" {
  subnet_id   = aws_subnet.private1.id
  security_groups  = [
      "${aws_security_group.allow_80.id}",
  ]
  tags = {
    Name = "primary_network_interface"
    }
}

resource "aws_security_group" "allow_80" {
  name        = "ALB"
  description = "allow port 80 for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.ALBSG.id]
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

resource "aws_instance" "ec2" {
  ami           = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"
  network_interface {
      network_interface_id = aws_network_interface.nic1.id
      device_index         = 0
      }
  tags = {
    Name = "EC2"
  }
}