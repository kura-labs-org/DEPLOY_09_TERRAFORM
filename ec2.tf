/* resource "aws_instance" "jenkins_ec2" {
  //This is the AMI for Ubuntu in US east 1
  ami           = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"

  key_name        = "east1key.pem"
  security_groups = ["${aws_security_group.ubuntu_ec2.name}"]

  subnet_id = aws_subnet.public01.id

  associate_public_ip_address = true



  tags = {
    Name = "Ubuntu-Terraform"
  }

}


   
resource "aws_security_group" "ubuntu_ec2" {
  name        = "ubuntu-deploy08-sg"
  description = "Ubuntu security group for terraform"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

} */