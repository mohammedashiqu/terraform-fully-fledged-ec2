terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "helloworld"
  }
}
resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/25"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-terraform"
  }
}
resource "aws_security_group" "ssh" {
  name = "security-group"
  description = "security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "terraform route table"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}
resource "aws_instance" "ec2" {
  ami = "ami-0b0dcb5067f052a63"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.sshkey.id
  security_groups = [aws_security_group.ssh.id]
  tags = {
    Name = "ec2-instance"
  }
}
resource "aws_route_table_association" "route-table-association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.subnet.id
}
resource "aws_route" "route" {
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_key_pair" "sshkey" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkwNYoJHpLN5Fkd8rYduv18pk11RX3Y2HOPUZHLob5S5OZnmFgvqJPJMFPC/08Hje7Zlf5gDsiTn9XHx0K0hwfB3XMRU8k34EXIHKk/Yckto0V9KcPEa0YGKwnu17vEMzA9kek2ruBVDHBJ/wIV35/bXvhzbvCd8yovOJ9RmZX36NBw+NteYlOL8GBucGGIVprxSMPTbRjS4aa65FlZzAk1ZZDZ4sZ59PPTJlBrjjt7dcvIHfPAZFlfB7vIRnSZ17+vMv39BLZi8k2Q8oxuP3D8T7LNqXRdHAHDL2MGabt3lcDfRB7dLZSM6AGPcaxJbktXxnGVR6qVwhylom9q7KZgxAE68sz5NYiPkB1eUoNJxVf5ArdTDClVS/f+5krfuYrH8LaHIMijs0IrwpuKXVo+8CHUStf7gKCOby9DsQcVyr90m5g1CnGoThLrgMMUIZ75iVBhpCk+56jmMuBlp/cDK8/H/ROiTBKIf9yrZQ0WoLaSU1hO0Hq1Pg1mLM5Dak= ashiq@INBook_X1"
}
