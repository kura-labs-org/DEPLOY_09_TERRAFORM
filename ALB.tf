resource "aws_alb_target_group" "tgroup" {
  name     = "alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_alb_target_group.tgroup.arn
  target_id        = aws_instance.ec2_private.id
  port             = 80
}

resource "aws_security_group" "alb" {
  name        = "tf_alb_sg"
  description = "load balancer security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
    
    
  }

  # outbound traffic.
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "alb" {
  name            = "tf-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = [aws_subnet.public01.id, aws_subnet.public02.id]
}



resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgroup.arn}"
    type             = "forward"
  }
}


