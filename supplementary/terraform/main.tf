provider "aws" {
  region = "us-east-1" # Update to your preferred region
}

# --- Data Sources ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "bubble-alb-sg"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = data.aws_vpc.default.id

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
}

resource "aws_security_group" "ec2_sg" {
  name        = "bubble-ec2-sg"
  description = "Allow HTTP from ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Load Balancer ---
resource "aws_lb" "bubble_alb" {
  name               = "bubble-works-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_target_group" "bubble_tg" {
  name     = "bubble-works-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.bubble_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bubble_tg.arn
  }
}

# --- Launch Template ---
resource "aws_launch_template" "bubble_lt" {
  name_prefix   = "bubble-works-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Download and run the setup script
              curl -O https://raw.githubusercontent.com/Innocent9712/barakat-2025-third-semester-learning-resource/main/supplementary/bubble-works/scripts/setup.sh
              chmod +x setup.sh
              sudo ./setup.sh
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "bubble-works-instance"
    }
  }
}

# --- Auto Scaling Group ---
resource "aws_autoscaling_group" "bubble_asg" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.bubble_tg.arn]
  availability_zones  = ["us-east-1a", "us-east-1b"]

  launch_template {
    id      = aws_launch_template.bubble_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bubble-works-asg"
    propagate_at_launch = true
  }
}

# --- Outputs ---
output "alb_dns_name" {
  value       = aws_lb.bubble_alb.dns_name
  description = "The DNS name of the load balancer"
}
