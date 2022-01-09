resource "aws_lb_target_group" "Ec2-TG" {
  name     = "Ec2-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.Ec2-TG.arn
  target_id        = module.ec2_instance.id
  port             = 80
}

resource "aws_security_group" "lb_SG" {
  name        = "lb_SG"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
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
  }

  tags = {
    Name = "lb_SG"
  }
}

resource "aws_lb" "deploy9_lb" {
  name                       = "deploy9-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_SG.id]
  subnets                    = [aws_subnet.public01.id, aws_subnet.public02.id]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}