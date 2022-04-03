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

# update/setup the machine
ssh root@${IP} "apt update ;TERM=linux DEBIAN_FRONTEND=noninteractive  apt dist-upgrade -y ; apt install wireguard netfilter-persistent -y ; umask 077 && cd /etc/wireguard/ && wg genkey | tee privatekey | wg pubkey > publickey"


PUBKEY_SERVER=$(ssh root@${IP} "sudo cat /etc/wireguard/publickey")
PRIVKEY_SERVER=$(ssh root@${IP} "sudo cat /etc/wireguard/privatekey")
echo "[*] Server pubkey:  " ${PUBKEY_SERVER}
echo "[*] Server privkey: " ${PRIVKEY_SERVER}



PRIVKEY_CLIENT=$(wg genkey)
PUBKEY_CLIENT=$(echo ${PRIVKEY_CLIENT}|wg pubkey)
echo "[*] Client pubkey: " ${PUBKEY_CLIENT}


cat <<EOF > wgserver.conf
[Interface]
Address = 192.160.0.1/32
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
#DNS = 192.168.2.1 

[Peer]
PublicKey = __PUBLIC_KEY__
Endpoint =  __IP__:51829
AllowedIPs = 0.0.0.0/0, ::0
PersistentKeepalive = 21
EOF


sed -i  "s|__PRIVATE_KEY__|${PRIVKEY_SERVER}|g"  wgserver.conf
sed -i "s|__PUBLIC_KEY__|${PUBKEY_CLIENT}|g" wgserver.conf


sed -i  "s|__PRIVATE_KEY__|${PRIVKEY_CLIENT}|g" wgclient.conf
sed -i  "s|__PUBLIC_KEY__|${PUBKEY_SERVER}|g" wgclient.conf
sed -i  "s|__IP__|${IP}|g" wgclient.conf


# Upload config
scp wgserver.conf root@${IP}:/etc/wireguard/wg0.conf
# setup iptables
echo "[*] Configuring routing."
ssh root@${IP} "sudo iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT ; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE ; systemctl enable netfilter-persistent ; netfilter-persistent save"

# setup sysctl forwarding settings
echo "[*] Enabling ip_forward."
ssh root@${IP} "echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf && sysctl -p"

# enable service
ssh root@${IP} "systemctl enable wg-quick@wg0 ; wg-quick up wg0"

echo ""
echo -e "[*] Client config\n--------"
cat wgclient.conf
echo "--------"
