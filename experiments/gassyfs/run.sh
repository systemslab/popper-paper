#!/bin/bash

set -e
set -x

# cleanup with inventory specified by CLEANUP env
if [ ! -z $CLEANUP ]; then
  ansible-playbook -e "@vars/all.yml" -i $CLEANUP site/cleanup.yml
  exit 0
fi

# run all tmpfs tests
for w in dd git ceph kernel samtools; do
    export ANSIBLE_LOG_PATH="logs/ansible-tmpfs-${w}.log"
    export INVENTORY="inventory/1-node"
    export ARGS="-e @vars/all.yml -e @vars/tmpfs.yml -e nnodes=1 -i $INVENTORY"
    ansible-playbook $ARGS site/tmpfs.yml workloads/${w}.yml
    CLEANUP=inventory/1-node ./run.sh
done

# run scalability tests
for w in dd git ceph kernel samtools; do
  for i in 1 2 3 4 5 6; do
    for s in udp; do
      export ANSIBLE_LOG_PATH="logs/ansible-${s}-${w}-${i}.log"
      export INVENTORY="inventory/${i}-node"
      export ARGS="-e @vars/all.yml -e @vars/${s}.yml -e nnodes=${i} -i $INVENTORY"
      ansible-playbook $ARGS site/${s}.yml workloads/${w}.yml
      CLEANUP=inventory/${i}-node ./run.sh
    done
  done
done

