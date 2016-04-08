#!/bin/bash

set -e
set -x

ansible-playbook -e "@vars/all.yml" ../site/cleanup.yml
