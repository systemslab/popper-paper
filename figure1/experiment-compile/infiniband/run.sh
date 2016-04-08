#!/bin/bash

set -e
set -x

ansible-playbook site/site.yml ../workload-git.yml
ansible-playbook site/cleanup.yml

ansible-playbook site/site.yml ../workload-kernel.yml
ansible-playbook site/cleanup.yml

ansible-playbook site/site.yml ../workload-ceph.yml
ansible-playbook site/cleanup.yml
