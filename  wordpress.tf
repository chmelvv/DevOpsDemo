# Load Balancer
resource "aws_lb" "wordpress" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.www.id]
  subnets = [aws_subnet.public1.id, aws_subnet.public2.id]
}

# Target Group
resource "aws_lb_target_group" "wordpress" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

# Listener
resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

# EC2 Instance
resource "aws_instance" "wordpress1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.www.name]

  tags = {
    Name = "WordPress1"
  }

  user_data = file("setup_wordpress.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "wordpress2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  security_groups = [aws_security_group.www.name]

  tags = {
    Name = "WordPress2"
  }

  user_data = file("setup_wordpress.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "wordpress1" {
  target_group_arn = aws_lb_target_group.wordpress.arn
  target_id        = aws_instance.wordpress1.id
  port             = 80
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "wordpress2" {
  target_group_arn = aws_lb_target_group.wordpress.arn
  target_id        = aws_instance.wordpress2.id
  port             = 80
}
