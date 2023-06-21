#!/bin/bash
set -x -o errexit -o nounset -o pipefail
declare -ax ip_addresses_compute_nodes=$ip_addresses_compute_nodes_string

# Install and prepare the virtual environment
sudo apt install python3-venv

# Create virtual environment and activate it 
python3 -m venv kolla-venv
source  kolla-venv/bin/activate

# Install the latest version of pip and some pip packages:
pip install -U pip
pip install 'ansible>=4,<6'
sudo apt install -y python3-docker
pip install wheel

# Configure Ansible
sudo mkdir -p /etc/ansible
sudo bash -c 'cat << EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF'

# Install Kolla-Ansible
pip install git+https://opendev.org/openstack/kolla-ansible@stable/zed

# Create the /etc/kolla directory
sudo mkdir -p /etc/kolla
sudo chown kolla:kolla /etc/kolla

# Copy globals.yml and passwords.yml to /etc/kolla directory 
cp -r ./kolla-venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla

# Copy all-in-one inventory file into the current directory
cp ./kolla-venv/share/kolla-ansible/ansible/inventory/multinode .

# Edit multinode inventory file
cat << EOF > multinode
# These initial groups are the only groups required to be modified. The
# additional groups are for more control of the environment.
[control]
# These hostname must be resolvable from your deployment host
control ansible_ssh_user=kolla ansible_become=True ansible_private_key_file=/home/kolla/.ssh/id_ed25519
 
# The network nodes are where your l3-agent and loadbalancers will run
# This can be the same as a host in the control group
[network]
control ansible_connection=local

[compute]
EOF

echo "----->>> ${ip_addresses_compute_nodes[@]}"
# Add the ip addresses of the compute nodes to the multinode inventory file
for ip in "${ip_addresses_compute_nodes[@]}"; do
    echo "$ip ansible_ssh_user=kolla ansible_become=True ansible_private_key_file=/home/kolla/.ssh/id_ed25519" >> multinode
done

cat << EOF >> multinode 
[monitoring]
control ansible_connection=local
 
[storage]
control ansible_connection=local
 
[deployment]
localhost       ansible_connection=local
EOF

tail -n +34 /home/kolla/kolla-venv/share/kolla-ansible/ansible/inventory/multinode >> /home/kolla/multinode


# Install Ansible Galaxy dependencies
cd /home/kolla
kolla-ansible install-deps

# Generate random passwords for kolla services
kolla-genpwd

# echo "Which IP address should we use for kolla_internal_vip_address?"
# export INTERFACE=$(ip -br addr | grep "$IP_ADDRESS" | cut -d' ' -f1) 

# echo $IP_ADDRESS
# echo $INTERFACE

# Edit globals.yml file (stored in /etc/kolla/globals.yml)
cat << EOF >  /etc/kolla/globals.yml
workaround_ansible_issue_8743: yes
kolla_base_distro: "ubuntu"
kolla_internal_vip_address: "$IP_ADDRESS"
enable_haproxy: "no"
neutron_external_interface: "br_ex_port"
network_interface: "$INTERFACE"
neutron_plugin_agent: "openvswitch"
enable_neutron_provider_networks: "yes"
enable_openstack_core: "yes"
nova_console: "novnc"
nova_compute_virt_type: "qemu"
enable_cinder: "yes"
enable_cinder_backup: "no"
enable_cinder_backend_lvm: "no"
enable_cinder_backend_iscsi: "no"
enable_openvswitch: "{{ enable_neutron | bool and neutron_plugin_agent != 'linuxbridge' }}"
fernet_token_expiry: 86400
glance_backend_file: "yes"
cinder_volume_availability_zone: internal
cinder_volume_group: "cinder-volumes"
cinder_backend_ceph: "yes"
ceph_cinder_user: "admin"
ceph_cinder_keyring: "ceph.client.admin.keyring"
EOF

mkdir /etc/kolla/config
mkdir /etc/kolla/config/cinder
mkdir /etc/kolla/config/nova
mkdir /etc/kolla/config/cinder/cinder-volume

sudo chmod +x /root/init-ceph.sh
script_path_ceph="/root/init-ceph.sh"
echo "Copying script to $CEPH_NODE_IP..."
sudo scp "$script_path_ceph" root@"$CEPH_NODE_IP":/root/init-ceph.sh
echo "Executing script on $CEPH_NODE_IP..."
sudo ssh root@"$CEPH_NODE_IP"  "bash  /root/init-ceph.sh $CEPH_NODE_IP"


sudo scp root@"$CEPH_NODE_IP":/etc/ceph/ceph.conf /etc/kolla/config/cinder/ceph.conf
sudo scp root@"$CEPH_NODE_IP":/etc/ceph/ceph.client.admin.keyring /etc/kolla/config/cinder/cinder-volume/ceph.client.admin.keyring
sudo scp root@"$CEPH_NODE_IP":/etc/ceph/ceph.client.admin.keyring /etc/kolla/config/nova/ceph.client.admin.keyring

sudo chown kolla:kolla /etc/kolla/config/cinder/ceph.conf 
sudo chown kolla:kolla /etc/kolla/config/cinder/cinder-volume/ceph.client.admin.keyring
sudo chown kolla:kolla /etc/kolla/config/nova/ceph.client.admin.keyring
sed -i 's/\t//g' /etc/kolla/config/cinder/ceph.conf
sed -i 's/\t//g' /etc/kolla/config/cinder/cinder-volume/ceph.client.admin.keyring
sed -i 's/\t//g' /etc/kolla/config/nova/ceph.client.admin.keyring


kolla-ansible -i ./multinode bootstrap-servers

kolla-ansible -i ./multinode prechecks

kolla-ansible -i ./multinode deploy

# Install the OpenStack client
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
