# --- 1) Security Group: allow HTTP inbound, allow all outbound ---
resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow HTTP inbound"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from allowed CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_http_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}

# --- 2) IAM role for EC2 to use SSM Session Manager ---
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "${var.name_prefix}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach AWS-managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# --- 3) Find latest Amazon Linux 2023 AMI (x86_64) ---
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

# --- 4) EC2 instance with Nginx installed via user_data ---
resource "aws_instance" "web" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              set -e

              dnf update -y

              # Ensure SSM Agent is installed + running (for Session Manager)
              dnf install -y amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent

              # Install and start Nginx
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx

              echo "<h1>${var.name_prefix} - Nginx is running!</h1>" > /usr/share/nginx/html/index.html
              EOF  user_data = <<-EOF
              #!/bin/bash
              set -e
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>${var.name_prefix} - Nginx is running!</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "${var.name_prefix}-web-ec2"
  }
}
