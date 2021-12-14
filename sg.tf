#Private EC2 Security Group Configuration
 resource "aws_security_group" "web_traffic" {
  name        = "web_traffic"
  description = "Security group for private EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_traffic"
  }
}

#Application Load Balancer Security Group Configuration
 resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "worldwide"
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
    Name = "Application Load Balancer"
  }
}

#Application Load Balancer Target Group Configuration
resource "aws_lb_target_group" "tec2-1" {
  name     = "tec2-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

#Application Load Balancer Target Group Attachment Configuration
resource "aws_lb_target_group_attachment" "tgroup1" {
  target_group_arn = aws_lb_target_group.tec2-1.arn
  target_id        = aws_instance.P-EC2.id
  port             = 80
}


#RDS Database Security Group Configuration
resource "aws_security_group" "RDS-SG" {
  name        = "RDS-SG"
  description = "Open channel from the EC2 to the RDS Database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.web_traffic.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}