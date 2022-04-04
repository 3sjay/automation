packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "esjay-wireguard"
  instance_type = "t2.micro"
  region        = "eu-central-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
  provisioner "shell" {    
    inline = [
      "sudo apt-get clean",
      "sudo apt-get update",
      "DEBIAN_FRONTEND=noninteractive sudo apt dist-upgrade -y",
      "sudo apt install -y wireguard netfilter-persistent",
      "sudo iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT ; sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE ; sudo systemctl enable netfilter-persistent ; sudo netfilter-persistent save",
      "echo net.ipv4.ip_forward=1 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
    ]  
  }
}

