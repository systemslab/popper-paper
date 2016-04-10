#! /bin/bash

set -e
set -x

# make sure that we have all the code
cd ..
git submodule update --init --recursive

# setup ulimits for infininband
echo "* soft memlock unlimited" | sudo tee -a /etc/security/limits.conf
echo "* hard memlock unlimited" | sudo tee -a /etc/security/limits.conf

# install EPEL and Docker
sudo yum install -y wget
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm 
sudo rpm -ivh epel-release-7-5.noarch.rpm
sudo yum update -y
curl -fsSL https://get.docker.com/ | sh
sudo usermod -aG docker ${USER}

# workaround for a Centos bug
sudo yum reinstall -y polkit
sudo systemctl start polkit
sudo service docker start

echo
echo "===================="
echo "DONE: please logout, login, and execute:"
echo "   $ ulimit -l unlimited"
echo 
