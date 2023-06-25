#!/bin/bash
set -x -o errexit -o nounset -o pipefail

apt install -y cephadm 
CEPH_NODE_IP=$1

cephadm bootstrap --single-host-defaults --mon-ip $CEPH_NODE_IP 
cephadm shell ceph orch apply osd --all-available-devices
cephadm shell ceph osd pool create volumes 64 64 replicated 
cephadm shell ceph osd pool application enable volumes rbd