# VPC
resource "aws_vpc" "ex1_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "ex1-vpc"
  }
}

# Subnet in us-east-1a
resource "aws_subnet" "ex1_subnet_a" {
  vpc_id                  = aws_vpc.ex1_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ex1-subnet-a"
  }
}

# Subnet in us-east-1b
resource "aws_subnet" "ex1_subnet_b" {
  vpc_id                  = aws_vpc.ex1_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ex1-subnet-b"
  }
}


resource "aws_internet_gateway" "ex1" {
  vpc_id = aws_vpc.ex1_vpc.id
}


resource "aws_route_table" "ex1" {
  vpc_id = aws_vpc.ex1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ex1.id
  }
}

resource "aws_route_table_association" "ex1" {
  subnet_id      = aws_subnet.ex1_subnet_a.id
  route_table_id = aws_route_table.ex1.id
}

resource "aws_route_table_association" "ex1b" {
  subnet_id      = aws_subnet.ex1_subnet_b.id
  route_table_id = aws_route_table.ex1.id
}


# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for the instance"
  vpc_id = aws_vpc.ex1_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# Launch Configuration
resource "aws_launch_configuration" "ex1" {
  image_id        = var.image_id 
  instance_type   = var.instance_type
  key_name = var.key_name
  security_groups = [aws_security_group.instance_sg.id]

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo apt-get install -y docker-compose
git clone https://github.com/chaimco579/ex3.git
cd ex3 && docker-compose up -d

EOF

}
  
# Auto Scaling Group
resource "aws_autoscaling_group" "ex1" {
  launch_configuration = aws_launch_configuration.ex1.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.ex1_subnet_a.id, aws_subnet.ex1_subnet_b.id]
  
  tag {
    key                 = "EX1"
    value               = "EX1-instance"
    propagate_at_launch = true
  }

}
