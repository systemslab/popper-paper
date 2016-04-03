SC16: Experiments and Results
=============================

This repository has our experiments for our SuperComputing '16 submission. 

Install
-------

These experiments were run on [CloudLab](https://www.cloudlab.us). We have a 3-node Centos7.1 baremetal setup, so you can instantiate a cluster from our [GassyFS Profile](https://www.cloudlab.us/p/5fd60b18-f5d0-11e5-b570-99cadac50270). Select the Clemson cluster, since these nodes have infiniband. On all nodes:

1. Setup passwordless SSH and sudo
2. Install [Docker](https://docs.docker.com/engine/installation/)
3. Setup up unlimited open files:

   ```bash
   sudo echo "* soft memlock unlimited" >> /etc/security/limits.conf
   sudo echo "* hard memlock unlimited" >> /etc/security/limits.conf
   ulimit -l unlimited
   ```

Quickstart
----------

1. Start an experiment master (a container with Ansible v2.0.1.0):

   ```bash
  docker run --rm -it \
    --name="emaster" \
    -v `pwd`:/experiments \
    -v ~/.ssh:/root/.ssh \
    michaelsevilla/emaster
   ```

2. Choose an experiment and setup the hosts:

   ```bash
   [EXPERIMENT_MASTER] cd /experiments/figure1
   [EXPERIMENT_MASTER] cp hosts.template hosts
   [EXPERIMENT_MASTER] vim hosts
   ```

3. Configure the `ssh_servers` value in the group variables:

   ```bash
   [EXPERIMENT_MASTER] vim group_vars/all
   ```

4. Start your experiment!
   
   ```bash
   [EXPERIMENT_MASTER] ansible-playbook experiment.yml
   ``` 

Troubleshooting
---------------

Check to make sure everything installed smoothly:

   ```bash
   # Should return unlimited
   $ ulimit -l

   # Should show no running images
   $ docker ps 
   ```

EOF 
