#Private EC2 Configuration
resource "aws_instance" "P-EC2" {
  ami = "ami-083654bd07b5da81d" # AMI of us-east-1 Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private01.id
  security_groups = [aws_security_group.web_traffic.id]

  tags = {
    Name = "Private-EC2"
  }
}

