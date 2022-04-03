#!/bin/bash
## currently removed as updates are performed in packer
# update the system
#apt update
#apt dist-upgrade -y

# create the 'user' user for ssh tunneling
useradd --shell /bin/false -m user
mkdir /home/user/.ssh/
yes '' |  ssh-keygen -N '' -f /home/user/.ssh/id_rsa
cp /home/user/.ssh/id_rsa.pub /home/user/.ssh/authorized_keys
chown -R user:user /home/user/.ssh
