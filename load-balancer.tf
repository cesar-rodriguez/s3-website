# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "public_elb_1" {
  name        = "public-elb-1"
  description = "Public Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  # HTTP access from anywhere
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
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
}

resource "aws_elb" "public_elb" {
  name = "public-elb"

  subnets = aws_subnet.public.*.id
  security_groups = [
    "${aws_security_group.public_elb_1.id}"
  ]
  instances = aws_instance.web.*.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/app/index.html"
    interval            = 15
  }

  connection_draining = true
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name = "public-elb"
  }
}

output "elb_dns" {
  description = "The DNS Name of the ELB"
  value       = aws_elb.public_elb.dns_name
}
