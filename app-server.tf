data "aws_ami" "latest" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for web servers
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Web Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/16",
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "web" {
  count         = 1
  ami           = data.aws_ami.latest.image_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.public[count.index].id
  user_data              = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
service httpd start
mkdir -p /var/www/html/app/
echo "<html><head><title>Terrascan - Secure your Infrastructure as Code</title></head><body><img width="500" src="/static/terrascan_logo.png" /></body></html>" > /var/www/html/app/index.html
EOF
  tags = {
    Name = "ec2-${count.index}"
  }
}
