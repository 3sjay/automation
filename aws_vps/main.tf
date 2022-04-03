provider "aws" {
  region = var.region
}

resource "aws_instance" "esjay-vps" {
  key_name      = "aws_key"
  ami           = var.instance_ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = "${file("./setup.sh")}"

  tags = {
    Name = "esjay-vps-tf"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    timeout     = "4m"
  }
}


resource "aws_security_group" "instance" {
  name = "allow ingress 22,80,443,8000"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "public_ip" {
  value       = aws_instance.esjay-vps.public_ip
  description = "The public IP of the AWS instance"
}

resource "aws_key_pair" "deployer" {
  key_name    = "aws_key"
  public_key  = "${file("~/.ssh/id_rsa.pub")}"
}
