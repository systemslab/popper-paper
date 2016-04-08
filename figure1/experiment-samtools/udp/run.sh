#!/bin/bash

set -e
set -x

ansible-playbook site/site.yml ../workload.yml
ansible-playbook site/cleanup.yml
