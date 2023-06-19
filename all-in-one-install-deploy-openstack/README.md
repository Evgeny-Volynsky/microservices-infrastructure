
## Installation and Deployment of OpenStack using Kolla-Ansible on VM 

Prerequirements: We assume that the machine has the following specs:
- Ubuntu 22.04 VM
- 16 GB RAM
- 2 network interfaces
- 2 disk partitions

In this folder you can find 2 scripts. To start the installation you should create the executable of the init.sh script by 

```bash
  chmod +x init.sh
```

and then run it by

```bash
  ./init.sh
```

Note: Make sure that both scripts are in the same directory.

The installation can take a long time, but you should be watching it as it will ask for the users input for the following variables:
- the ip that will be used to host OpenStack
- the partition where cinder will be deployed

To change / add new ssh key. You can add the following line in the init.sh script:
```bash
  echo ssh-key | sudo tee -a /home/kolla/.ssh/authorized_keys
```

If you rebuild your VM with a new OS, after you already installed Openstack, before running again the installation scripts, you should run the following commands to delete the cinder partitions:
```bash
  vgremove cinder-volumes
  pvremove /dev/sda --force --force 
```
Note: instead of /dev/sda you can use the partition you selected during the installation process


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
  ssh -N  -L 8080:private_ip:80 kolla@public_ip
```

To connect to the Horizon dashboard, you can open http://localhost:8080/ in your browser and login with the following credentials:
- username: admin
- password: you can find it in passwords.yaml, by using the following command :
 ```bash
  cat /etc/kolla/passwords.yml | grep "keystone_admin_password"
```