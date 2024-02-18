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

resource "aws_instance" "app_server" {
  ami           = "ami-0f74c08b8b5effa56"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}