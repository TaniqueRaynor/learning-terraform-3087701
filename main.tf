data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default"{
   default=true
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.web_sg.security_group_id]

  tags = {
    Name = "web instance"
  }
}

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name    = "web_new"

  vpc_id  = data.aws_vpc.default.id

  ingress_rules       = ["http-80-tcp","http-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

}

 resource "aws_security_group" "web"{
     name="web"
     description="Allow http and https. outbound everything"

     vpc_id= data.aws_vpc.default.id
  }

  resource "aws_security_group_rule" "web_http"{
     type        = "ingress"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

     security_group_id = aws_security_group.web.id
  }

   resource "aws_security_group_rule" "web_https"{
     type        = "ingress"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

     security_group_id = aws_security_group.web.id
  }

   resource "aws_security_group_rule" "web_evrything_out"{
     type        = "egress"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]

     security_group_id = aws_security_group.web.id
  }
