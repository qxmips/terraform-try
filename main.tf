terraform {
  required_version = ">=0.13.0"
    backend "s3" {
    bucket = "qx-tf-backend"
    key    = "terraform-try"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu2004" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "current" {}


locals {
  service_name = "test"
  owner        = data.aws_caller_identity.current.account_id
}


locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}

variable "instance1_name" {
  type = string
  default = "ubuntu2004"
}

resource "aws_instance" "instance1" {
  count = 2
  ami           = data.aws_ami.ubuntu2004.id
  instance_type = "t2.micro"
  tags = merge( 
              local.common_tags, 
              {
                Name = "${var.instance1_name}-${count.index+1}"
          
              })
}

output "ami" {
  value = data.aws_ami.ubuntu2004
  
}

output "instance1" {
  value = aws_instance.instance1
}

output "callerid" {
  value = data.aws_caller_identity.current
}