terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        
    }
  }
}

#configure aws provider

provider "aws" {
  region = "us-east-2"
}

#create a vpc
resource "aws_vpc" "My-VPC" {
  cidr_block = var.cidr_block[0]

  tags = {
    Name = "My-VPC"
  }
  
}

#create Subnet
resource "aws_subnet" "Mylab-Subnet1" {
  vpc_id = aws_vpc.My-VPC.id
  cidr_block = var.cidr_block[1]

  tags = {
    Name = "Mylab-Subnet1"
  }
  
}

resource "aws_internet_gateway" "Mylab-intGW" {
  vpc_id = aws_vpc.My-VPC.id

  tags = {
    Name = "Mylab-intGW"
  } 
}

#Security Group
resource "aws_security_group" "Mylab-SecurityGroup" {
  vpc_id = aws_vpc.My-VPC.id
  name = "Mylab Sec Group"
  description = "to allow inbound & outbound traffic to mylab"

  dynamic ingress {
    iterator = port
    for_each = var.ports
    content {
      from_port = port.value
      to_port = port.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    } 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow traffic"
  }
}

resource "aws_route_table" "Mylab-RouteTable" {
  vpc_id = aws_vpc.My-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Mylab-intGW.id

  }

  tags = {
    Name = "Mylab-RouteTable"
  }
  
}

resource "aws_route_table_association" "Mylab-Assn" {
  subnet_id = aws_subnet.Mylab-Subnet1.id
  route_table_id = aws_route_table.Mylab-RouteTable.id
  
}

#create EC2 - Jenkins
resource "aws_instance" "Jenkins" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.Mylab-SecurityGroup.id]
  subnet_id = aws_subnet.Mylab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./installJenkins.sh")

  tags = {
    Name = "Jenkins Server"
  }
  
}
#create EC2 - Ansible
resource "aws_instance" "AnsibleController" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.Mylab-SecurityGroup.id]
  subnet_id = aws_subnet.Mylab-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./installAnsibleCN.sh")

  tags = {
    Name = "Ansible - Control Node"
  }
  
}