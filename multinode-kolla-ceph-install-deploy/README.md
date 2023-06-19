
## Installation and Deployment of Multinode OpenStack with ceph using Kolla-Ansible on VMs

This installation kit assumes that the cluster running openstack will consist of a control node, any number of compute nodes and one node running only ceph. Due to hardware limitations, the script was tested for one and two compute nodes only. 

Prerequirements: 
For the nodes particating in the openstack cluster we expect the following specs:
- Ubuntu 22.04 LTS
- at least 8 GB RAM, but 16 GB advised for compute nodes
- 1 private network interface for inter node communication
- 4 core processor at 2.5 GHz or higher

the control node also should have another network interface that is accessable to the desired audience.



For the the Ceph Node, or potential future nodes:
- Ubuntu 22.04 LTS
- 1 network interface reachable by the control node
- 8 GB RAM
- 4 core processor at 2.5 GHz or higher
- an uninitilialized drive without a file system with at least 50GB of storage



In this folder you can find several scripts. 

To complete the installation and deployment of an Openstack multinode cluster with one of the nodes exclusively running ceph, the following steps are required:

On your local machine, you should initialize the communication between all nodes by creating the executable of the init-communication.sh script by
```bash
  chmod +x init-communication.sh
```

Before running the script you should create an ssh key on the control node that will be used in the communication between all nodes. This can be done by:
```bash
  ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519 <<< y
```

and then run the script on your local machine by 
```bash
  ./init-communication.sh
```

The `init-communication` script will ask the user for the following input, so have the following values prepared:
- ssh public key of the control node
- public ips of the compute nodes and the node running ceph

The `init-communication` script assumes that you can ssh into all nodes that will be part of the openstack cluster and will add the public key of the control node to all other nodes in the cluster such that the actual installation script will be able to setup the entire cluster from the control node. 

After the `init-communication` script was run successfully, you should connect again to the control node and put all the files of this folder in the root of the vm. 

After that, you should create the executable of the `init-control.sh` script by
```bash
  chmod +x init-control.sh
```
and run it by 
```bash
  ./init-control.sh
```

The `init-control.sh` script asks for the following input from the user:
- the ip that will be used to host OpenStack control node 
- the number of compute nodes thay you want to deploy
- the internal ip addresses of the compute nodes
- the ip address of the node runnning ceph

After having this information, the `init-control` script will prepare the setup of the compute nodes by accessing the compute nodes through ssh and by copying the `init-compute.sh` installation script on the computes nodes and running it to prepare the nodes for the kolla installation that is realized by control node.  

After setting up the compute nodes, the `init-control.sh` script will continue setting up the node running ceph, where cephadm is installed as a single host and where an osd pool is created with the rbd application tag is created. This will ensure that any instace running on top of openstack will have acess to ceph. 

After this step is done, you can find the ceph dashboard details, where the user can use the UI provided by cephadm to monitor and configure ceph manually if needed. 

After all other nodes are prepared, the `init-control.sh` script will start the kolla installation and setup process across all nodes.


The `clean.sh` and `clean-ceph.sh` script were created during the development process to ease the debugging process and can be used in case a reinstallation is needed / the current installation fails due to some bad configuration / input.

The `clean.sh` script can be used in the control node and all compute nodes, while the clean-ceph.sh can only be used in the node running ceph. As they are not used in the installation and setup process directly, you will have to manually copy them in the root of each node if you will want to use them. 

Note: Make sure that all scripts are in the same directory (in root only)

To change / add new ssh key. You can add the following line in the `init-control.sh` script:
```bash
  echo ssh-key | sudo tee -a /home/kolla/.ssh/authorized_keys
```

To be able to access OpenStack CLI, you should run: 
```bash
  source /etc/kolla/admin-openrc.sh 
```

Then switch to kolla user, enter the virtual environment kolla-venv and then you can have full access to the OpenStack CLI.
```bash
  cd /home/kolla
  source kolla-venv/bin/activate
```

To be able to login into horizon, you should ssh-tunnel as follows:
```bash
  ssh -N  -L 8080:private_ip_control:80 kolla@public_ip_control
```

To connect to the Horizon dashboard, you can open http://localhost:8080/ in your browser and login with the following credentials:
- username: `admin`
- password: you can find it in passwords.yaml, by using the following command :
 ```bash
  cat /etc/kolla/passwords.yml | grep "keystone_admin_password"
```