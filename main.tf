
provider "aws" {
  region = "ap-south-1"
}

terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }
}

resource "aws_instance" "web" {
  count = 4
  key_name                  = "anandlavuzoho2022"
  ami                       = data.aws_ami.amazon-linux.id
  instance_type             = "t2.micro"
  vpc_security_group_ids    = [aws_security_group.instance-sg.id]

  tags = {
        Name = "HelloWorld"
      }
}

resource "null_resource" "ProvisionRemoteHostsIpToAnsibleHosts" {
  count = 4
  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${element(aws_instance.web.*.public_ip, count.index)}"
    private_key = "${file("/home/anand/Downloads/anandlavuzoho2022.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd.service",
      "sudo systemctl enable httpd.service",
      "sudo systemctl restart httpd.service"
    ]
  }

}

resource "aws_security_group" "instance-sg" {
  name = "web_ssh_sgname"
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

resource "aws_security_group_rule" "asg_allow_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  security_group_id = aws_security_group.instance-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
