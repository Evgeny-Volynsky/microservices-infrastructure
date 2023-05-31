#!/bin/bash
set -x -o errexit -o nounset -o pipefail

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
cp ./kolla-venv/share/kolla-ansible/ansible/inventory/all-in-one .

# Install Ansible Galaxy dependencies
kolla-ansible install-deps

# Generate random passwords for kolla services
kolla-genpwd

echo "Which IP address should we use for kolla_internal_vip_address?"
export INTERFACE=$(ip -br addr | grep "$IP_ADDRESS" | cut -d' ' -f1) 


echo $IP_ADDRESS
echo $INTERFACE

# Edit globals.yml file (stored in /etc/kolla/globals.yml)
cat << EOF >  /etc/kolla/globals.yml
workaround_ansible_issue_8743: yes
kolla_base_distro: "ubuntu"
kolla_internal_vip_address: "$IP_ADDRESS"
enable_haproxy: "no"
network_interface: "$INTERFACE"
neutron_external_interface: "br_ex_port"
neutron_plugin_agent: "openvswitch"
enable_neutron_provider_networks: "yes"
enable_openstack_core: "yes"
nova_console: "novnc"
nova_compute_virt_type: "qemu"
enable_cinder: "yes"
enable_cinder_backup: "no"
enable_cinder_backend_lvm: "yes"
enable_openvswitch: "{{ enable_neutron | bool and neutron_plugin_agent != 'linuxbridge' }}"
fernet_token_expiry: 86400
glance_backend_file: "yes"
cinder_volume_group: "cinder-volumes"
cinder_volume_availability_zone: internal
EOF

# Bootstrap servers with kolla deploy dependencies
kolla-ansible -i ./all-in-one bootstrap-servers

# Do pre-deployment checks for hosts
kolla-ansible -i ./all-in-one prechecks

# Finally proceed to actual OpenStack deployment
kolla-ansible -i ./all-in-one deploy

# OpenStack requires a clouds.yaml file where credentials for admin user are set. To generate this file: 
kolla-ansible post-deploy

# Install the OpenStack client
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master