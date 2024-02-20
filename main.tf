resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "dev-public-1"
  }

}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"
  tags = {
    Name = "dev-public-2"
  }

}

resource "aws_subnet" "public-subnet-3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1c"
  tags = {
    Name = "dev-public-3"
  }

}

resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "dev-private-1"
  }

}

resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"
  tags = {
    Name = "dev-private-2"
  }

}



resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev_internet_gateway"
    }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-3-association" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_eip" "nat-eip" {
  vpc = true
   tags = {
      Name = "nat-eip"
      }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
      Name = "nat-gateway"
      }
}


resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.main.id

 ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_key_pair" "terra_auth" {
  key_name   = "authkey"
  public_key = file("~/.ssh/authkey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  count = 2
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

resource "aws_lb" "loadb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dev_sg.id]

  subnets = ["subnet-0a39036d186aba976", "subnet-0801b0907dfc24699","subnet-0b6f4b47bce8f6b9d"] 

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lb_target" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-054bc8f9b936de5a5" 
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.loadb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target.arn
    type             = "forward"
  }
}

