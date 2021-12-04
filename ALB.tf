/* resource "aws_lb" "alb-deployment9" {
  name               = "deployment-9-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public01.id, aws_subnet.public02.id]

  

  tags = {
    Name = "Deploy9 loadblancer"
  }
}

resource "aws_security_group" "alb-sg" {
    name        = "Deployment-9-Loadbalancer-SG"
  description = "Deployment 9 security group for alb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ubuntu_ec2.id]
  }
  
} */