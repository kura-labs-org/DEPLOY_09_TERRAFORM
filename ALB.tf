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

resource "aws_security_group" "alb-sg" {
  name        = "Deployment-9-Loadbalancer-SG"
  description = "Deployment 9 security group for alb"
  vpc_id = aws_vpc.main.id

}

resource "aws_security_group_rule" "allow_all_port_80_traffic" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks     = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.alb-sg.id

}

resource "aws_security_group_rule" "direct_traffic_2_ec2" {
  type            = "egress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_group_id = aws_security_group.alb-sg.id
  source_security_group_id = aws_security_group.ubuntu_ec2.id
  

}
