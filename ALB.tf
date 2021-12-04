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
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB GROUP"
  }
}