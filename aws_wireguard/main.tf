
provider "aws" {
  region = var.region
}

resource "aws_security_group" "instance" {
  name = "allow ingress TCP 22,80,443,8000. UDP 51829"

  ingress {
    from_port = var.server_port
    to_port   = var.server_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 51829
    to_port   = 51829
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpnInstance" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name      = "aws_key"


  provisioner "local-exec" {
    command = "bash setup-local.sh ${self.public_ip}"
  }

}

output "public_ip" {
  value       = aws_instance.vpnInstance.public_ip
  description = "The public IP of the AWS instance"
}


resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
