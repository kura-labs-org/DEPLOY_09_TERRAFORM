# DEPLOY_09_TERRAFORM

<h1 align=center>Deployment 9</h1>

## Goal:

Welcome to Deployment 9. For this deployment you will need to follow the directions below to generate Terraform code to deploy the following resources:

## Terraform Challenge
Create the following resources in AWS using the latest Terraform version (do not use external modules):

## Architecture:

## Software Tools:

   * **AWS account**: set up
   * **Terraform**: here is a [link](https://learn.hashicorp.com/tutorials/terraform/install-cli) to the resource used to install Terraform.

## Procedure:

### Part 1 - VPC
1. Create a new VPC with:
  * 5 subnets (2 public, 1 private, 2 internal)
  * 2 route tables (public & private)
  * an Internet Gateway
  * and 1 NAT Gateway (in 1 of the private subnets)

2. Subnets are defined as:
 * Public - route to Internet Gateway (for any ipv4 address)
 * Private - route to NAT Gateway (for any ipv4 address)
 * Internal - do not associate any route table in Terraform (main/default route table will be associated by default which only has a route to the local/private network)

**Note**: You can decide which network range to use.

### Part 2 - EC2
1. Create 1 EC2 instance in the private subnet with:
  * An Ubuntu AMI (version of your choosing)
  * Instance type/size, tags, and other settings of your choosing
2. Create a security group for the EC2 with the following rules:
  * Ingress: allow port 80 traffic from the ALB security group
  * Egress: allow all outbound traffic to any ipv4 address

### Part 3 - Application Load Balancer (ALB)
1. Create 1 ALB in the 2 public subnets
2. Create a security group for the ALB with the following rules:
  * Ingress: allows only port 80 inbound traffic from any ipv4 address
  * Egress: allow only port 80 outbound traffic to the EC2 security group
3. Create a target group and add the EC2 instance to the group
4. Create an ALB listener that forwards traffic to the target group

**Note**: for this exercise the ALB is not accepting HTTPS traffic, only HTTP

### Part 4 - RDS
1. Create 1 PostgreSQL RDS instance
  * Make it multi-az
  * Name, instance type/size, tags, db username/password, and other settings of your choosing
2. Create a security group for the RDS with the following rule:
  * Ingress: allow traffic to its port from the EC2 security group
3. Create a DB subnet group for the RDS consisting of the 2 internal subnets




## Sources Visited:
1. https://harshitdawar.medium.com/launching-a-vpc-with-public-private-subnet-nat-gateway-in-aws-using-terraform-99950c671ce9
2. https://www.cdw.com/content/cdw/en/articles/cloud/aws-vpc-terraform.html
3. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
4. https://hiveit.co.uk/techshop/terraform-aws-vpc-example/03-create-an-rds-db-instance/
5. https://www.bogotobogo.com/DevOps/Terraform/Terraform-VPC-Subnet-ELB-RouteTable-SecurityGroup-Apache-Server-2.php
  

![image](https://p2zk82o7hr3yb6ge7gzxx4ki-wpengine.netdna-ssl.com/wp-content/uploads/terraform-x-aws-1.png)
