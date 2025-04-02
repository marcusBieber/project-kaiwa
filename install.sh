#!/bin/bash

# Terraform Deployment & Ansible Setup Script
# 31.03.2025
# Author: Marcus Bieber

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

echo -e "\nVerzeichnis für Log-Dateien wird bereinigt oder ertellt falls nicht vorhanden..."
mkdir -p $ANSIBLE_DIR/logs/
rm -rf $ANSIBLE_DIR/logs/*
echo -e "logs-Verzeichnis bereit...✅\n"

cd $ANSIBLE_DIR
ansible-playbook jenkins.yml > $ANSIBLE_DIR/logs/jenkins_$(date +"%Y%m%d_%H%M").log 2>&1 &
ansible-playbook jenkins_docker_node.yml > $ANSIBLE_DIR/logs/jenkins_docker_node_$(date +"%Y%m%d_%H%M").log 2>&1 &
ansible-playbook app_ec2.yml > $ANSIBLE_DIR/logs/app_ec2_$(date +"%Y%m%d_%H%M").log 2>&1 &
ansible-playbook docker_app_ec2.yml > $ANSIBLE_DIR/logs/docker_app_ec2_$(date +"%Y%m%d_%H%M").log 2>&1 &
cd ..

echo -e "\nStarte Playbooks...\n"

playbooks=("jenkins.yml" "jenkins_docker_node.yml" "app_ec2.yml" "docker_app_ec2.yml")

for playbook in "${playbooks[@]}"; do
  echo "$playbook 🚀"
  sleep 1  # Optional: Verzögerung für bessere Sichtbarkeit
done

echo -e "\nWarten auf Fertigstellung der Playbooks, Logs werden im Verzeichnis /ansible/logs gespeichert...⏳\n"

wait

echo -e "Playbooks beendet.\n"

# Log-Dateien auf Fehler überprüfen
log_files=($ANSIBLE_DIR/logs/*.log)

for log in "${log_files[@]}"; do
    if [[ -f "$log" ]]; then
        echo "Prüfe $log auf Fehler..."
        
        result=$(grep -Eo "failed=[0-9]+" "$log" | tail -n1)

        if [[ "$result" == "failed=0" ]]; then
            echo -e "✅ Abgeschlossen.\n"
        else
            echo -e "Fehler gefunden in $log ❌\n"
            echo -e "Bitte überprüfen Sie die Log-Datei für weitere Informationen.\n"
        fi
    fi
done

echo -e "Konfiguration der Instanzen beendet.\n"