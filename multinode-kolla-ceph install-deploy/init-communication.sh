#!/bin/bash
set -x -o errexit -o nounset -o pipefail

echo "Add the public key of the controller node that will be added to the other nodes in the cluster"
PUBLIC_KEY_CONTROL=$(gum input --prompt "Enter the public key of the control node:")

echo "How many compute nodes you would like to setup?"
NO_COMPUTE_NODES=$(gum input --prompt "Enter the number of compute nodes:")

re='^[0-9]+$'
if ! [[ $NO_COMPUTE_NODES =~ $re ]]; then
  echo "Invalid input. Please enter a valid number."
  exit 1
fi


ip_addresses_compute_nodes=()

# Loop to prompt for IP addresses
for ((i = 0; i < $NO_COMPUTE_NODES; i++)); do
  ip=$(gum input --prompt "Enter IP address of compute node $(($i + 1)):")
  ip_addresses_compute_nodes+=("$ip")
done

# Display entered IP addresses
echo -e "Entered IP addresses:\n${ip_addresses_compute_nodes[*]}"
# export ip_addresses_compute_nodes="$ip_addresses_compute_nodes"}

# get_ip_addresses "$NO_COMPUTE_NODES"

# Get the IP address for the node running ceph
export CEPH_NODE_IP=$(gum input --prompt "Please enter the IP address for the node running ceph: ")

copy_and_execute_script() {
  local ip_addresses=("$@")

  for ip in "${ip_addresses[@]}"; do
    echo "Append public key to $ip..."
    # sudo scp "$script_path" root@"$ip":/root/.ssh/authorized_keys
    ssh root@"$ip" "echo '$PUBLIC_KEY_CONTROL' >> /root/.ssh/authorized_keys"
  done
}

# Example usage
# ip_addresses=("192.168.0.1" "192.168.0.2" "192.168.0.3")

copy_and_execute_script "${ip_addresses_compute_nodes[@]}"
# copy_and_execute_script "${ip_addresses_compute_nodes[@]}" "$script_path"

echo "Append public key to $CEPH_NODE_IP..."
ssh root@"$CEPH_NODE_IP" "echo '$PUBLIC_KEY_CONTROL' >> /root/.ssh/authorized_keys"
