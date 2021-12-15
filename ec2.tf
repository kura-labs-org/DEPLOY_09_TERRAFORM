#security group for ubuntu ec2
resource "aws_security_group" "ubuntu_ec2" {
  name        = "ubuntu_ec2"
  description = "Allow port 80 inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyDep9UbuntuEc2"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "Dep9EC2" {
  ami             = "ami-0629230e074c580f2"
  instance_type   = "t2.micro"
  key_name        = "Python"
  security_groups = [aws_security_group.ubuntu_ec2.id]
  subnet_id       = aws_subnet.private01.id

  tags = {
    Name = "MyDeploymentEC2"
  }
}