terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "eu-west-1"

  default_tags {
    tags = {
      environment = "Dev"
      owner       = var.dev_email
      terraform   = true
    }
  }
}

# Create a vpc
resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "  dev_vpc"
  }
}

#Create an igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

#Use data source to get a list of all availability zones in a region
data "aws_availability_zones" "availability_zones" {}

#Create public subnet az1
resource "aws_subnet" "dev_public_subnet_az1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.pub_sub_az1_cidr
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "dev public subnet az1"
  }
}

#Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "dev-public-rt"
  }
}

#Associate public subnet in az1 to "public route table"
resource "aws_route_table_association" "az1_pub_sub_rt_association" {
  subnet_id      = aws_subnet.dev_public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

#Create ec2 security group
resource "aws_security_group" "ec2_sg" {
  name   = "sonarqube sg"
  vpc_id = aws_vpc.dev_vpc.id
  
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  //sonarqube default port is 9000
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.port_9000_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create sonarqube ec2
resource "aws_instance" "sonarqube" {
  ami             = var.ec2_ami
  instance_type   = "t2.small"
  subnet_id       = aws_subnet.dev_public_subnet_az1.id
  security_groups = [aws_security_group.ec2_sg.id]
  user_data       = file("templatefile.tpl")

  tags = {
    Name = "sonarqube server"
  }
}