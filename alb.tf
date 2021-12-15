resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
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
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #protocol         = "-1"  removed it because this is equivalent to all

    security_groups = [aws_security_group.ubuntu_ec2.id]
  }

  tags = {
    Name = "Deployment9ALB_sg"
  }
}

resource "aws_lb_target_group" "dep9tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "dep9tgat" {
  target_group_arn = aws_lb_target_group.dep9tg.arn
  target_id        = aws_instance.Dep9EC2.id
  port             = 80
}


resource "aws_lb" "dep9lb" {
  name               = "dep9lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public01.id, aws_subnet.public02.id]

  enable_deletion_protection = false

  tags = {
    Environment = "Deployment9"
  }
}

resource "aws_lb_listener" "dep9lbl" {
  load_balancer_arn = aws_lb.dep9lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dep9tg.arn
  }
}