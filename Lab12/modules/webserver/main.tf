# Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id
  name = "${var.env_prefix}-web-sg-${var.instance_suffix}"
  description = "Webserver SG allowing HTTP, HTTPS, SSH"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env_prefix}-default-sg" }
}

# Key Pair
resource "aws_key_pair" "ssh-key" {
  key_name = "${var.env_prefix}-serverkey-${var.instance_suffix}"
  public_key = file(var.public_key)
}

# EC2 Instance
resource "aws_instance" "myapp-server" {
  ami = "ami-05524d6658fcf35b6"
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.web_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file(var.script_path)

  tags = { Name = "${var.env_prefix}-ec2-instance-${var.instance_suffix}" }
}
