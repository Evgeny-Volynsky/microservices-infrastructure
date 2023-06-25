#!/bin/bash
set -x -o pipefail

fsid=$(grep fsid /etc/ceph/ceph.conf | awk -F "=" '{print $2}' )
cephadm rm-cluster --fsid $fsid --force
rm -rf /etc/ceph
lvs_output=$(lvs --noheadings -o lv_name,vg_name)
if [[ -z "$lvs_output" ]]; then
  echo "No logical volumes found."
  exit 0
fi
while read -r lv_name vg_name; do
  echo "Deleting logical volume $lv_name in volume group $vg_name"
  lvremove -f "$vg_name/$lv_name"
  vgremove -f "$vg_name"
done <<< "$lvs_output"

pvs_output=$(pvs --noheadings -o pv_name)

if [[ -z "$pvs_output" ]]; then
  echo "No physical volumes found."
  exit 0
fi

while read -r pv_name; do
  echo "Deleting physical volume $pv_name"
  pvremove -ff "$pv_name"
done <<< "$pvs_output"
