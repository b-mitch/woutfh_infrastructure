# create application load balancer
# terraform aws create application load balancer
resource "aws_lb" "alb" {
    name               = "alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_security_group.id]
    subnets            = [aws_subnet.public_prod_subnet_az1.id, aws_subnet.public_prod_subnet_az2.id]
    enable_deletion_protection = false

    tags = {
        Name = "alb"
    }
}

# create target group for the blue instance
# terraform aws create target group
resource "aws_lb_target_group" "blue" {
    name        = "blue-group"
    target_type = "instance"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id

    health_check {
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200,301,302"
        path = "/"
        port = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    tags = {
        Name = "blue-group"
    }
}
# create target group for the green instance
# terraform aws create target group
resource "aws_lb_target_group" "green" {
    name        = "green-group"
    target_type = "instance"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id

    health_check {
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200,301,302"
        path = "/"
        port = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    tags = {
        Name = "green-group"
    }
}

# create listener for the application load balancer
# terraform aws create listener
resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_lb_target_group.blue.arn
        type             = "forward"
    }
}

# create target group attachment for the production ec2 instance in az1
# terraform aws create target group attachment
resource "aws_lb_target_group_attachment" "blue_group_attachment_az1" {
    target_group_arn = aws_lb_target_group.blue.arn
    target_id        = aws_instance.prod_instance_az1.id
    port             = 80
}

# create target group attachment for the production ec2 instance in az2
# terraform aws create target group attachment
resource "aws_lb_target_group_attachment" "green_group_attachment_az2" {
    target_group_arn = aws_lb_target_group.green.arn
    target_id        = aws_instance.prod_instance_az2.id
    port             = 80
}

# define listener rules for blue group with heavier weight
# terraform aws create listener rules
resource "aws_lb_listener_rule" "rule1" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# define listener rules for green group with lighter weight
# terraform aws create listener rules
resource "aws_lb_listener_rule" "rule2" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
