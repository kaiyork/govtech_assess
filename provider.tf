terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.2"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "~/.aws/creds"

}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.terra_auth.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.public-subnet-1.id
  user_data = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }
  tags = {
    name = "dev-node"
  }

}
