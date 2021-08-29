provider "aws" {
  region = "eu-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

locals {
  name              = "example-ec2-module"
  tags = {
    Name       = "moduletest"
  }
}

module "ec2" {
  source = "../../"

  name = local.name

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"

  tags = local.tags
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}