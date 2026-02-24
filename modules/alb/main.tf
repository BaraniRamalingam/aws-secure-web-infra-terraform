# --- 1) Security Group for ALB ---
# This is the "front door" security group.
# It allows inbound HTTP (80) from the allowed CIDR (internet or your IP).
# It allows outbound to anywhere (so it can reach targets).
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP inbound to ALB"
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
    Name = "${var.name_prefix}-alb-sg"
  }
}

# --- 2) Application Load Balancer ---
# Must be in PUBLIC subnets to be reachable from internet.
resource "aws_lb" "this" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnet_ids

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

# --- 3) Target Group ---
# A target group is the "destination set" where ALB will forward traffic.
# We use HTTP on port 80, and ALB will health-check the targets.
resource "aws_lb_target_group" "this" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

# --- 4) Register your EC2 instance as a target ---
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_instance_id
  port             = 80
}

# --- 5) Listener: HTTP 80 -> forward to target group ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
