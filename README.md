# automation
terraform and other automation scripts


## setup\_wireguard

Setup wireguard server on a VPS, creates and prints the config for the client too.

* requires that root user can login via ssh private key. 

Usage:
```
bash setup_wireguard.sh <ip/hostname of VPS>
```


## aws\_vps

Automate the setup of a VPS on AWS. Another user 'user' is also created which is just to setup ssh tunnels. On each server a new keypair is created for this user, located in the respective users' home folder.

The `setup.sh` script is executed after the server is created.


```
# set the AWS API ENV variables
export AWS_ACCESS_KEY_ID=<snip>
export AWS_SECRET_ACCESS_KEY=<snip>

# initialize
terraform init
# setup the server 
terraform apply
# if not needed anymore
terraform destroy
```

Change the following in main.tf if another public/private key pair should be used to access the VPS.

```
  public_key  = "${file("~/.ssh/id_rsa.pub")}"
```

