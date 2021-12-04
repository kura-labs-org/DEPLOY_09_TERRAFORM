#Amazon Load Balancer Configuration
resource "aws_lb" "pload" {
  name               = "pload"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public01.id, aws_subnet.public02.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
    Name = "pload"
  }
} 