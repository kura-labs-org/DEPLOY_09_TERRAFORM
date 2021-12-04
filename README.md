# DEPLOY_09_TERRAFORM

<h1 align=center>Deployment 9</h1>

Welcome to Deployment 9. For this deployment you will need to follow the directions below to generate Terraform code to deploy the following resources:

## Terraform Challenge
Create the following resources in AWS using the latest Terraform version (do not use external modules):

## Part 1 - VPC
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

## Part 2 - EC2
1. Create 1 EC2 instance in the private subnet with:
  * An Ubuntu AMI (version of your choosing)
  * Instance type/size, tags, and other settings of your choosing
2. Create a security group for the EC2 with the following rules:
  * Ingress: allow port 80 traffic from the ALB security group
  * Egress: allow all outbound traffic to any ipv4 address

## Part 3 - Application Load Balancer (ALB)
1. Create 1 ALB in the 2 public subnets
2. Create a security group for the ALB with the following rules:
  * Ingress: allows only port 80 inbound traffic from any ipv4 address
  * Egress: allow only port 80 outbound traffic to the EC2 security group
3. Create a target group and add the EC2 instance to the group
4. Create an ALB listener that forwards traffic to the target group

**Note**: for this exercise the ALB is not accepting HTTPS traffic, only HTTP

## Part 4 - RDS
1. Create 1 PostgreSQL RDS instance
  * Make it multi-az
  * Name, instance type/size, tags, db username/password, and other settings of your choosing
2. Create a security group for the RDS with the following rule:
  * Ingress: allow traffic to its port from the EC2 security group
3. Create a DB subnet group for the RDS consisting of the 2 internal subnets


Be sure to include the following below in your pull request: 

## Requirements
- [ ] Add all Terraform files to the pull request.
- [ ] Document the process, issues and anything you decided to do differently.
- [ ] Screenshot samples of your infrastucture from AWS and include in your PR.
- [ ] DO NOT upload the `terraform.tfstate` file to the repo (it should be ignored by default)

![image](https://p2zk82o7hr3yb6ge7gzxx4ki-wpengine.netdna-ssl.com/wp-content/uploads/terraform-x-aws-1.png)


<h2> Documentation </h2>

This deployment challenge was done within a 5 hour span. The documentation used almost exclusively used Hashicorps documentation.

One of the issues that I ran into was an internal security one that involves passing a secret variable on to the CLI without passing that data on to git when pushing changes to code. This was solved using a [secrets.tfvars](https://learn.hashicorp.com/tutorials/terraform/sensitive-variables?in=terraform/0-14) that is called upon command, which will pass the secret to the variable, which then passes to the terraform file itself. ```terraform apply 
-var-file="secrets.tfvars"``` will be the command used here to pass the argument on for this part of the deployment.

For the deployment itself, part 1 can be done using a standard approach, but part 2 and 3 need to reference one another, so parts of 2 need to be done with parts of 3 and vice versa. Last, Part 4 with the database, the default settings on Hashicorp need to be updated to consider for the postgres change.
