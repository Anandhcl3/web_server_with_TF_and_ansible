
provider "aws" {
  region = "ap-south-1"
}

terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }

resource "aws_instance" "web" {
  ami           = data.amazon-linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance-sg.id]

  tags = {
        Name = "HelloWorld"
      }
}

resource "aws_security_group" "instance-sg" {
  name = web_ssh_sg
}


resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  security_group_id = aws_security_group.instance-sg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  security_group_id = aws_security_group.instance-sg.id
  cidr_blocks       = ["0.0.0.0/0"]

}
