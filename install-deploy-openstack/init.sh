#!/bin/bash
set -x -o errexit -o nounset -o pipefail

# Add a user named 'kolla' with no password
sudo useradd -m kolla

# Grant 'kolla' user sudo privileges
echo 'kolla ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/kolla

# Create .ssh directory for kolla
sudo mkdir /home/kolla/.ssh

# Set the correct permissions
sudo chmod 700 /home/kolla/.ssh

# Add public keys to kolla's authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWO997ZygpIs+41KpvcZ9glH+vv/Wz0j59x1owYPyP6 iulia.cornea@tum.de' | sudo tee /home/kolla/.ssh/authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhaKOV4rywl4Nlcl7Hk+v66hDNjaqTavSp4ng4IvatS ben' | sudo tee -a /home/kolla/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLczJN6THjOvvhQ1a61GKPgHAp3+eQohG5oPUzFtyyxK0IvPKOn9nULVhV7iJCmBPX5ZLikKqgWh+C+kvyw/QJID5UKcQxpqFaUnDmuOyS4T3QHYA4+aoBheYiaKiwoD8rgmyoJJ+7CY6Y8a62OLHCosYHemg0QhgOeeZC45mMgbFtECXhpbngq5fRx1D2Y23ddBBIIwkePh8SsJfu86VF9UXqsKn/Lbecx04SjRTtO+zClTKznvNZIkQx2ZKBuDyZ2tmg1kKh0oO0UnplJtM3gJiDWhQMx/Yn9/qSIIHbhff1xdkP2oVRCFqEzX2KKfDesOYkhTrfkyTg1Iw+i/a6ER1sJBSDcK6EsXpap50tIjHjqKu2NBOWR/wMJJy0Sxu8vSuBPD8/h0b/mIlHaLGZWOAp+XLDhBH5iPlaj9OSppQSEEJUDv1ba8p/rzL6FfiFDLKm5JgdV2vWEyyMBAu1GMsYmQNuOAGt5gXpIwP9mklpr3x6tCuZP53RtogCyeU= evgen@LAPTOP-565G8RJ0' | sudo tee -a /home/kolla/.ssh/authorized_keys

# Set the correct permissions and ownership
sudo chmod 600 /home/kolla/.ssh/authorized_keys
sudo chown -R kolla:kolla /home/kolla/.ssh

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list

# Update package list
sudo apt update
# Install necessary packages
sudo apt-get install -y git python3-dev libffi-dev gcc libssl-dev python3-selinux python3-setuptools python3-venv net-tools gum

echo "Which Device should we use for cinder volumes?" 
CINDER_PARTITION=$(gum choose --item.foreground 250 $(echo $(lsblk -o NAME -n -l -s| grep -E '^s|^v')))

echo "Which IP address should we use for kolla_internal_vip_address?"
export IP_ADDRESS=$(gum choose --item.foreground 250 $(echo $(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'))) 

sudo bash -c 'cat << EOF > /opt/network.sh
#!/bin/bash
set -x -o errexit -o nounset -o pipefail
sudo ip tuntap add mode tap br_ex_port
sudo ip link set dev br_ex_port up
export EXT_NET_CIDR='10.0.2.0/24'
export EXT_NET_RANGE='start=10.0.2.150,end=10.0.2.199'
export EXT_NET_GATEWAY='10.0.2.1'
EOF'

chmod +x /opt/network.sh

# Create dummy network interface on boot
sudo bash -c 'cat << EOF > /etc/systemd/system/tap-interface.service
[Unit]
Description=Create persistent tap interface

[Service]
ExecStart=/opt/network.sh
ExecStop=/sbin/ip link set dev br_ex_port down
RemainAfterExit=yes
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF'

systemctl daemon-reload
systemctl start tap-interface

# Create a new partition for cinder
sudo pvcreate /dev/$CINDER_PARTITION
sudo vgcreate cinder-volumes /dev/$CINDER_PARTITION
sudo vgs

# Switch to kolla user
chmod +x kolla.sh
sudo chown kolla:kolla kolla.sh
cp kolla.sh /home/kolla/
cd /home/kolla
sudo -u kolla  --preserve-env=IP_ADDRESS  ./kolla.sh

# Add netowrking rules required on reboot for openstack
sudo bash -c 'cat << EOF >> /opt/network.sh
sudo ifconfig br-ex \$EXT_NET_GATEWAY netmask 255.255.255.0 up
sudo iptables -t nat -A POSTROUTING -s \$EXT_NET_CIDR -o eth0 -j MASQUERADE
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -A FORWARD -o eth0 -i br-ex -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o br-ex -j ACCEPT
EOF'

systemctl daemon-reload
systemctl start tap-interface
