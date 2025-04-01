#!/bin/bash

# Terraform Deployment & Ansible Setup Script
# 31.03.2025
# Author: Marcus Bieber

echo -e "\nKonfiguration der Instanzen wird gestartet...🚀\n"

echo -e "logs-Verzeichnis wird bereinigt oder ertellt falls nicht vorhanden...💾\n"
mkdir -p ../ansible/logs/
rm -rf ../ansible/logs/*
echo -e "logs-Verzeichnis bereit...✅\n"

ansible-playbook ../ansible/jenkins.yml > ../ansible/logs/jenkins.log 2>&1 &
ansible-playbook ../ansible/jenkins_docker_node.yml > ../ansible/logs/jenkins_docker_node.log 2>&1 &
ansible-playbook ../ansible/app_ec2.yml > ../ansible/logs/app_ec2.log 2>&1 &
ansible-playbook ../ansible/docker_app_ec2.yml > ../ansible/logs/docker_app_ec2.log 2>&1 &

playbooks=("jenkins.yml" "jenkins_docker_node.yml" "app_ec2.yml" "docker_app_ec2.yml")

for playbook in "${playbooks[@]}"; do
  echo -e "$playbook wird gestartet...🚀\n"
  sleep 1  # Optional: Verzögerung für bessere Sichtbarkeit
done

wait
echo "...alle Playbooks wurden ausgeführt, die Logs befinden sich in ../ansible/logs...💾"
