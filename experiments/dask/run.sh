#!/bin/bash
echo "" > ansible.log && ansible-playbook -b -i inventory -e "@vars.yml" playbook.yml
