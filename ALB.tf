resource "aws_lb" "alb-deployment9" {
  name               = "deployment-9-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public01.id, aws_subnet.public02.id]



  tags = {
    Name = "Deploy9 loadblancer"
  }
}

### Security group rules for Load Balancer

resource "aws_security_group" "alb-sg" {
  name        = "Deployment-9-Loadbalancer-SG"
  description = "Deployment 9 security group for alb"
  vpc_id      = aws_vpc.main.id

}

resource "aws_security_group_rule" "allow_all_port_80_traffic" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.alb-sg.id

}

resource "aws_security_group_rule" "direct_traffic_2_ec2" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb-sg.id
  source_security_group_id = aws_security_group.ubuntu_ec2.id


}

### Target groups

resource "aws_lb_target_group" "target_group" {
  name     = "deploy9-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "deployment9-attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.jenkins_ec2.id
  port             = 80


}

resource "aws_lb_listener" "deployment09-listener" {
  load_balancer_arn = aws_lb.alb-deployment9.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
