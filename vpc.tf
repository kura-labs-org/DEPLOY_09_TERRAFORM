
# Create a new VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Main VPC"
  }
}


resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig1"
  }
}
