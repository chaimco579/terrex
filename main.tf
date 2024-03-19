# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for the instance"

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
  security_groups = [aws_security_group.instance_sg.name]
  
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
  availability_zones = ["us-east-1a", "us-east-1b"]


  tag {
    key                 = "EX1"
    value               = "EX1-instance"
    propagate_at_launch = true
  }

}
