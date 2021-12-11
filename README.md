# DEPLOY_09_TERRAFORM

<h1 align=center>Deployment 9</h1>

## Purpose 

The purpose of this deployment/repo was to create a VPC consiting of an EC2, RDS postgres database, and an application load balancer. 
The flow of data would be user -> internet -> loadbalancer -> EC2 -> RDS database. 

## Though Process

I structured the project into files designinating the resoruces they affect. Such as the vpc.tf file pertaining to the VPC and it's underlying features, and ec2.tf featuring the security groups and ec2 isntance.

### Creating the VPC

Utilized the terraform resource block "aws_vpc" to create a vpc named "Main VPC" with a cidr block of 10.0.0.0/18. 

I then created all the subnets required utilizing a variation of following code block. Changing the availability_zone tag for when I need a subnet in a different AZ as well as changing the cidr block since subnets can't share the same cidr block. 
```
resource "aws_subnet" "public01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public01"
  }
}
```

Next I created an internet gateway in order to allow the VPC to access the internet. 

Then added a nat gateway resource so the private subnets would be able to access services outside the VPC. 

Lastly configured a route table and the appropriate routes for the subnets to configure network traffic. 


### Creating the EC2

Created an EC2 using the terraform aws_instance resource block. Looked up the ami for an Ubuntu image in us east 1, and configured the instance to be a t2.micro (to keep it in the free tier). Lastly placed it in the private subnet that was creating in the vpc.tf file.
