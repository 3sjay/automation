variable "region" {
  default = "eu-central-1"
}

variable "instance_ami" {
  default = "ami-015653a3fd840f5ed"  # use value provided by the packer script
}

variable "instance_type" {
  default = "t2.micro"
}


variable "server_port" {
  description = "variable port to be allowed through the firewall"
  default     = 8000
  type        = number
}
