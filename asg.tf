resource "aws_launch_configuration" "terrascale" {
  instance_type   = "t2.micro"
  name_prefix     = "terraform-aws-asg"
  image_id        = data.aws_ami.ubuntu.id
  key_name        = aws_key_pair.terra_auth.id
  security_groups = [aws_security_group.dev_sg.id]
  user_data       = file("userdata.tpl")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terrascale" {
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.terrascale.name
  vpc_zone_identifier = ["subnet-0a39036d186aba976", "subnet-0801b0907dfc24699", "subnet-0b6f4b47bce8f6b9d"]
}

resource "aws_lb" "terrascale" {
  name               = "terrascale"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terramino_lb.id]
  subnets = ["subnet-0a39036d186aba976", "subnet-0801b0907dfc24699", "subnet-0b6f4b47bce8f6b9d"]
}
resource "aws_lb_listener" "terrascale" {
  load_balancer_arn = aws_lb.terrascale.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terrascale.arn
  }
}

resource "aws_lb_target_group" "terrascale" {
  name     = "asg-terramino"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_attachment" "terrascale" {
  autoscaling_group_name = aws_autoscaling_group.terrascale.id
  alb_target_group_arn   = aws_lb_target_group.terrascale.arn
}

resource "aws_security_group" "terrascale_instance" {
  name = "terrascale"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.terramino_lb.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id   = aws_vpc.main.id
}

resource "aws_security_group" "terramino_lb" {
  name = "terrascale-lb"
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

  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "terramino_scale_down"
  autoscaling_group_name = aws_autoscaling_group.terrascale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}


