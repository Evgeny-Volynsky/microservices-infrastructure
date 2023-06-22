#!/bin/bash
set -x  -o nounset -o pipefail

rm -rf /home/kolla/.ssh
rm -rf /home/kolla/
rm -rf /etc/kolla/config
userdel kolla

# vgremove cinder-volumes
# pvremove /dev/sda --force --force 
systemctl stop tap-interface
sudo ip link delete br_ex_port
