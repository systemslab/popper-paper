#!/bin/bash

set -e
set -x

cd infiniband
ansible-playbook experiment.yml

cd ../udp
ansible-playbook experiment.yml

cd ../tmpfs
ansible-playbook experiment.yml
