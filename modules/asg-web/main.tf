# --- Security Group for instances: ONLY allow HTTP from ALB SG ---
resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-asg-web-sg"
  description = "Allow HTTP only from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-asg-web-sg"
  }
}

# --- IAM for SSM ---
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "${var.name_prefix}-asg-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-asg-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# --- Latest Amazon Linux 2023 ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    dnf update -y

    # SSM Agent (usually present, but safe to ensure)
    dnf install -y amazon-ssm-agent || true
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    echo "<h1>${var.name_prefix} - Nginx is running (ASG)!</h1>" > /usr/share/nginx/html/index.html
  EOF
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-web-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-web-asg"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-web-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 60

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-web-asg"
    propagate_at_launch = true
  }
}
