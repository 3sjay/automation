#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: " $0 " <ip/domain>"
  exit 1
fi

if ! [ -x "`which wg`" ]; then
  echo "[!] Make sure the cmd utility 'wg' is in \$PATH"
  exit 1
fi

IP=$1

while ! nc -z ${IP} 22; do   
  sleep 3 # wait three seconds until port is open
done

# Gen wireguard keys, accept host for ssh
ssh -o StrictHostKeyChecking=accept-new ubuntu@${IP} "sudo su -c 'umask 077; wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey'"

PUBKEY_SERVER=$(ssh -o StrictHostKeyChecking=accept-new ubuntu@${IP} "sudo cat /etc/wireguard/publickey")
PRIVKEY_SERVER=$(ssh ubuntu@${IP} "sudo cat /etc/wireguard/privatekey")
echo "[*] Server pubkey:  " ${PUBKEY_SERVER}
echo "[*] Server privkey: " ${PRIVKEY_SERVER}


PRIVKEY_CLIENT=$(wg genkey)
PUBKEY_CLIENT=$(echo ${PRIVKEY_CLIENT}|wg pubkey)
echo "[*] Client pubkey: " ${PUBKEY_CLIENT}


cat <<EOF > wgserver.conf
[Interface]
Address = 192.160.2.1/32
ListenPort = 51829
PrivateKey = __PRIVATE_KEY__

[Peer]
PublicKey = __PUBLIC_KEY__
AllowedIPs = 192.160.2.0/24
EOF

cat <<EOF >wgclient.conf
[Interface]
Address = 192.160.2.2
PrivateKey = __PRIVATE_KEY__
DNS = 1.1.1.1

[Peer]
PublicKey = __PUBLIC_KEY__
Endpoint =  __IP__:51829
AllowedIPs = 0.0.0.0/0, ::0
PersistentKeepalive = 21
EOF


# Replace the public and private keys for client and server
# '-i' and '-e' used as this works for Unix and Linux sed's
sed -i -e "s|__PRIVATE_KEY__|${PRIVKEY_SERVER}|g"  wgserver.conf
sed -i -e "s|__PUBLIC_KEY__|${PUBKEY_CLIENT}|g" wgserver.conf

sed -i -e "s|__PRIVATE_KEY__|${PRIVKEY_CLIENT}|g" wgclient.conf
sed -i -e "s|__PUBLIC_KEY__|${PUBKEY_SERVER}|g" wgclient.conf
sed -i -e "s|__IP__|${IP}|g" wgclient.conf

## remove the {wgclient,wgserver}.conf-e files created by sed -i -e on OSX
rm wg*-e


scp wgserver.conf ubuntu@${IP}:/home/ubuntu/wgserver.conf

# Further setup, these cmds could be written to a .sh file, uploaded to the server
# and executed there.
ssh ubuntu@${IP} "sudo mv /home/ubuntu/wgserver.conf /etc/wireguard/wg0.conf"
ssh ubuntu@${IP} "sudo chown root:root /etc/wireguard/wg0.conf"
ssh ubuntu@${IP} "sudo chmod 600 /etc/wireguard/wg0.conf"
ssh ubuntu@${IP} "sudo systemctl enable wg-quick@wg0 ; wg-quick up wg0"


ssh ubuntu@${IP} "sudo sysctl -w net.ipv4.ip_forward=1 && sudo sysctl -p"
ssh ubuntu@${IP} "sudo iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT"
ssh ubuntu@${IP} "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
ssh ubuntu@${IP} "sudo systemctl enable netfilter-persistent"
ssh ubuntu@${IP} "sudo netfilter-persistent save"

echo "[*] wg{server,client}.conf written to current working directory."

