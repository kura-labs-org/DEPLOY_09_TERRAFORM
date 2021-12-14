#Security Group for Load Balancer
resource "aws_security_group" "load_balancer_sg" {
  name        = "lb_SG"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow port 80 inbound traffic from any IPv4"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow port 80 outbound traffic to the EC2 Security Group"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load balancer security group"
  }
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
