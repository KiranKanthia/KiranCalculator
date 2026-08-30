terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "3.0"
    }
  }
  }

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "scmvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "scmsubnet" {
  vpc_id     = aws_vpc.scmvpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "scmgw" {
  vpc_id = aws_vpc.scmvpc.id
}

resource "aws_route_table" "scmroutetable" {
  vpc_id = aws_vpc.scmvpc.id
  route {
    cidr_block = "0.0.0.0/0"   
    gateway_id = aws_internet_gateway.scmgw.id 
}
}

resource "aws_route_table_association" "scmroutetableassociation" {
  subnet_id      = aws_subnet.scmsubnet.id
  route_table_id = aws_route_table.scmroutetable.id
}

resource "aws_security_group" "scmsg" {
  name        = "scm-security-group"
  description = "Security group for SCM"
  vpc_id      = aws_vpc.scmvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "scminstance" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "c7i-flex.large"
  subnet_id     = aws_subnet.scmsubnet.id
  vpc_security_group_ids = [aws_security_group.scmsg.id]

  associate_public_ip_address = "true"
  availability_zone = "us-east-1a"
}

output "instance_public_ip" {
  value = aws_instance.scminstance.public_ip
}
