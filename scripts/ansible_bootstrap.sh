#!/bin/bash

cd /home/ubuntu
git clone https://github.com/onboarding-trainee-tasks/task-4-ansible
cd task-4-ansible
git checkout onb-4-ansible
git fetch
git pull

sudo chown -R ubuntu:ubuntu /home/ubuntu/task-4-ansible

# ansible-playbook -i inventory.ini playbook.yml