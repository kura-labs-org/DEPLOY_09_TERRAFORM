resource "aws_instance" "jenkins_ec2" {
  //This is the AMI for Ubuntu in US east 1
  ami           = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ubuntu_ec2.id]

  subnet_id = aws_subnet.private01.id

  associate_public_ip_address = true



  tags = {
    Name = "Ubuntu-Terraform"
  }

}


   
resource "aws_security_group" "ubuntu_ec2" {
  name        = "ubuntu-deploy09-sg"
  description = "Ubuntu security group for terraform"
  vpc_id = aws_vpc.main.id

}

resource "aws_security_group_rule" "accept_traffic_from_lb" {
  type = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.ubuntu_ec2.id
  source_security_group_id = aws_security_group.alb-sg.id
  
}

resource "aws_security_group_rule" "outbound_rule_4_ec2" {
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "tcp"
  security_group_id = aws_security_group.ubuntu_ec2.id
  cidr_blocks     = [aws_vpc.main.cidr_block]
  
}