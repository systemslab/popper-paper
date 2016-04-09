#!/bin/bash
testname=`basename $1 .yml`
echo "" > ansible.log && ansible-playbook -b -i inventory -e "testname=${1}" -e "@${1}" playbook.yml
