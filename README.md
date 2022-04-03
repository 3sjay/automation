# automation
packer/terraform and other automation scripts

## aws\_wireguard

Create an AMI with packer and run then you can setup as many servers as you want with terraform. 
More info the the README.md


## setup\_wireguard.sh

Setup wireguard server on a VPS, creates and prints the config for the client too.

* requires that root user can login via ssh private key. 

Usage:
```
bash setup_wireguard.sh <ip/hostname of VPS>
```


## aws\_vps

Automate the setup of a VPS on AWS. Another user 'user' is also created which is just to setup ssh tunnels. On each server a new keypair is created for this user, located in the respective users' home folder.

More info in the README.md

Change the following in main.tf if another public/private key pair should be used to access the VPS.

```
  public_key  = "${file("~/.ssh/id_rsa.pub")}"
```

