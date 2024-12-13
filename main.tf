# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# VPC and Subnets
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
}

# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_1.id
  security_groups = [aws_security_group.ec2_sg.name]
}

# Create Elastic Load Balancer
resource "aws_lb" "main_lb" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.ec2_sg.id]
  subnets           = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

# Create Auto Scaling Group
resource "aws_launch_configuration" "web_launch_config" {
  name          = "web-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  security_groups = [aws_security_group.ec2_sg.id]
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  min_size             = 1
  max_size             = 3
  vpc_zone_identifier  = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  launch_configuration = aws_launch_configuration.web_launch_config.id
}

# Create Route 53 DNS Failover
resource "aws_route53_record" "dns_record" {
  zone_id = "your-zone-id"
  name    = "example.com"
  type    = "A"
  alias {
    name                   = aws_lb.main_lb.dns_name
    zone_id                = aws_lb.main_lb.zone_id
    evaluate_target_health = true
  }
}