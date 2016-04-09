#!/bin/bash


if [ -z $INVENTORY ]; then
  echo "ERROR: Please give me an inventory"
  echo "  INVENTORY=inventory/1-node $0"
  exit 0
fi
set -x
ansible-playbook -e "@vars/all.yml" -i $INVENTORY site/cleanup.yml
