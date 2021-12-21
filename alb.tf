#Security Group for Load Balancer
resource "aws_security_group" "load_balancer_sg" {
  name        = "lb_SG"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "load balancer security group"
  }
}

resource "aws_security_group_rule" "ingress_lb" {
  type              = "ingress"
  description       = "Allow port 80 inbound traffic from any IPv4"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.load_balancer_sg.id
}

resource "aws_security_group_rule" "egress_lb" {
  type                     = "egress"
  description              = "Allow port 80 outbound traffic to the EC2 Security Group"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  security_group_id        = aws_security_group.load_balancer_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}


#Creating the load balancer
resource "aws_lb" "load_balancer" {
  name                       = "deploy9loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_sg.id]
  subnets                    = [aws_subnet.public01.id, aws_subnet.public02.id]
  enable_deletion_protection = false

}

resource "aws_lb_target_group" "target_group_ec2" {
  name     = "deploy09targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.target_group_ec2.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}
