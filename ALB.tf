resource "aws_lb" "test" {
  name               = "firstALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSG.id]
  subnets            = [
      aws_subnet.public1.id,
      aws_subnet.public2.id

  ]

  enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "production"
  }
}

resource "aws_security_group" "ALBSG" {
  name        = "ALBGroup"
  description = "allow port 80 for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allows all in from 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.allow_80.id]
  }

  tags = {
    Name = "ALB GROUP"
  }
}

resource "aws_lb_target_group" "targetec1" {
  name     = "TargetEC21"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "attachmentec1" {
  target_group_arn = aws_lb_target_group.targetec1.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}