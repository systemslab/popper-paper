SC16: Experiments and Results
=============================

This repository has our experiments for our SuperComputing '16 submission. Do *NOT* clone this repository; It is part of our [infra](https://github.com/systemslab/infra.git) framework.

Install
-------

These experiments were run on [CloudLab](https://www.cloudlab.us). We have a 3-node Centos7.1 baremetal setup, so you can instantiate a cluster from our [GassyFS Profile](https://www.cloudlab.us/p/5fd60b18-f5d0-11e5-b570-99cadac50270). Select the Clemson cluster, since these nodes have infiniband. The install has an extra step to set up infiniband. On all nodes:

1. Setup passwordless SSH and sudo.

2. User our script to install infiniband and Docker:

   ```bash
   $ git clone --recursive https://github.com/systemslab/infra.git
   $ cd infra
   $ sudo bin/bootstrap-infiniband.sh
   ```

3. Check to make sure everything installed smoothly:

   ```bash
   # Should return unlimited
   $ ulimit -l

   # Should show no running images
   $ docker ps 
   ```

Quickstart
----------

1. Start an experiment master (a container with Ansible):

   ```bash
   $ bin/emaster.sh
   ```

2. Choose an experiment and setup the hosts:

   ```bash
   [EXPERIMENT_MASTER] cd sc16/experiment-bamsort
   [EXPERIMENT_MASTER] cp hosts.template hosts
   [EXPERIMENT_MASTER] vim hosts
   ```

3. Configure the SSH_SERVERS value in the group variables:

   ```bash
   [EXPERIMENT_MASTER] vim group_vars/all
   ```

4. Start your experiment!
   
   ```bash
   [EXPERIMENT_MASTER] ansible-playbook experiment.yml
   ``` 
