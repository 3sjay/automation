## Setup a Wireguard server on AWS with packer and terraform

Make sure that you have the AWS API secrets set as environment variables

### Create AMI Image
```
1. Init packer with AWS provider: `packer init .`   
2. Export AWS access key: `export AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY>` and export AWS secret: `export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_KEY>`
3. Validate packer file: `packer validate .`
4. Build AWS AMI `wireguard-vpn`: `packer build --force wireguard-vpn.pkr.hcl`
```

### Start a Wireguard VPN Server
```
1. Set the AMI id (output of the packer build command): `export TF_VAR_instance_ami=<YOUR AMI-ID>` or adjust the value in file `variables.tf:6`
1.1 Change the num_servers variable in `variables.tf` if you want more than one VPN server.
2. Initialize terraform provider: `terraform init`
3. Plan the execution of terraform: `terraform plan`
4. If everything is in the right configuration, create the plan: `terraform apply -auto-approve`
```

### Finally
Copy the created wgclient.conf into your Wireguard config file/GUI
