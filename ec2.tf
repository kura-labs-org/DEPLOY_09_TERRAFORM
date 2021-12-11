resource "aws_security_group" "tfec2-sg" {
  name        = "EC2-SG"
  description = "creating ec2 instance sg"
  vpc_id      = aws_vpc.main.id
  

# To Allow Port 80 Transport
ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups =[aws_security_group.alb.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

# To allow all outbound traffic to any ipv4 address
egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tcp_traffic"
  }

}

# Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
    ami                         = "ami-083654bd07b5da81d"
    associate_public_ip_address = false
    instance_type               = "t2.micro"
    key_name                    = "ClassKeyJenkins"
    #security_groups             = "tfec2-sg"
    subnet_id                      = aws_subnet.private01.id
    vpc_security_group_ids = [aws_security_group.tfec2-sg.id]
      tags = {
        "Name" = "EC2-PRIVATE"
  }
}