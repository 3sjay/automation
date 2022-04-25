variable "region" {
  default = "eu-central-1"
}

variable "instance_ami" {
  default = "ami-06f1f08254df2f400"
}

variable "instance_type" {
  default = "t2.micro"
}


variable "server_port" {
  description = "variable port to be allowed through the firewall"
  default     = 8000
  type        = number
}

variable "num_servers" {
  description = "Number of servers we want"
  default     = 1
  type        = number
}
