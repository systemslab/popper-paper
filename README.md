SC16: Experiments and Results
=============================

This repository has our experiments for our SuperComputing '16 submission. 

Install
-------

These experiments were run on [CloudLab](https://www.cloudlab.us). We have a 6-node Centos7.1 baremetal setup, so you can instantiate a cluster from our [GassyFS Profile](https://www.cloudlab.us/p/5fd60b18-f5d0-11e5-b570-99cadac50270). Select the Clemson cluster, since these nodes have infiniband. On all nodes:

1. Setup passwordless SSH and sudo

2. Install [Docker](https://docs.docker.com/engine/installation/) and setup infiniband. For Centos7.1, you can use:

  ```bash
  $ cd experiments; ./bootstrap.sh
  ```

Quickstart
----------

1. Start experiment master (i.e., a container with [Ansible](https://www.ansible.com/how-ansible-works)):

   ```bash
   $ cd experiments; ./emaster.sh
   ```

2. Choose an experiment and setup the cluster inventory:

   ```bash
   [EXPERIMENT_MASTER] cd experiment/multi-node
   [EXPERIMENT_MASTER] vim inventory/*
   ```

3. Start the experiment!

   ```
   [EXPERIMENT_MASTER] ./run.sh
   ```

Results and Logs
----------------

Inside the experiment directory there is a results and logs directory. These will be overwritten everytime you run an experiment... so you should try to commit the results along with the entire experiment directory before running a new job. This gives you a history of different experiments and helps us understand how small tweaks affect results.

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
