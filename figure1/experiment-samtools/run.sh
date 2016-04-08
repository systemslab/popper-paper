#!/bin/bash

set -e
set -x

args="-e logs_path=results/ansible-infiniband.log"
args="$args -e @vars/all.yml -e @vars/infiniband.yml"
ansible-playbook ${args} ../site/gassyfs.yml workloads/playbook.yml
./cleanup.yml

args="-e logs_path=results/ansible-udp.log"
args="$args -e @vars/all.yml -e @vars/udp.yml"
ansible-playbook ${args} ../site/gassyfs.yml workloads/playbook.yml
./cleanup.yml

args="-e logs_path=results/ansible-tmpfs.log"
args="$args -e @vars/all.yml -e @vars/tmpfs.yml"
ansible-playbook ${args} ../site/tmpfs.yml workloads/playbook.yml
./cleanup.yml
