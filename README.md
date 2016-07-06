[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org/repo/systemslab/popper-paper)

Popper repo for our ASPLOS '17 submission

# Install

These experiments were run on [CloudLab](https://www.cloudlab.us). We 
have a 6-node Centos7.1 baremetal setup, so you can instantiate a 
cluster from our [GassyFS 
Profile](https://www.cloudlab.us/p/5fd60b18-f5d0-11e5-b570-99cadac50270). 
Select the Clemson cluster, since these nodes have infiniband. On all 
nodes:

 1. Setup passwordless SSH and sudo on nodes.
 2. Install [Docker](https://docs.docker.com/engine/installation/)
 3. If running the multi-node experiments, setup infiniband 
    (single-node experiments don't need infiniband).

# Quickstart

Experiments are in the `experiments/` folder. For any experiment:

 1. Edit the `machines` file and add the hostname/IP of the nodes 
    where the experiment will run.
 2. Execute it:

    ```bash
    popper experiment run single-node
    ```

# Results and Logs

Inside the experiment directory there is a results and logs directory. 
These will be overwritten every time an experiment runs... so you 
should try to commit the results along with the entire experiment 
directory before running a new job. This gives you a history of 
different experiments and helps us understand how small tweaks affect 
results.
