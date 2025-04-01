#!/bin/bash

# Terraform Deployment & Ansible Setup Script
# 31.03.2025
# Author: Marcus Bieber

set -e  # Beende das Skript bei Fehlern

echo -e "\n🚀 Starte Terraform Deployment..."
terraform init
terraform apply -auto-approve
echo -e "\n🎉 Deployment abgeschlossen.\n"

# Terraform-Output abrufen und als Array speichern
echo -e "\n💻 Abrufen der IP-Adressen...\n"
JENKINS_IPS=($(terraform output -json jenkins_instances_ips | jq -r '.[]'))
WEB_IPS=($(terraform output -json web_instances_ips | jq -r '.[]'))

# Prüfen, ob 4 IPs vorhanden sind
if [ $((${#JENKINS_IPS[@]} + ${#WEB_IPS[@]})) -lt 4 ]; then
  echo -e "\n⚠️  Warnung: Es wurden weniger als 4 IP-Adressen gefunden!"
  echo -e "⚠️  Das Skript läuft trotzdem weiter...\n"
fi

# IP-Adressen den Hostgruppen zuweisen (leere Einträge werden als "MISSING" gesetzt)
JENKINS_IP=${JENKINS_IPS[0]:-"!!MISSING!!"}
JENKINS_DOCKER_NODE_IP=${JENKINS_IPS[1]:-"!!MISSING!!"}
APP_EC2_IP=${WEB_IPS[0]:-"!!MISSING!!"}
DOCKER_APP_EC2_IP=${WEB_IPS[1]:-"!!MISSING!!"}

KEY_NAME=$(terraform output -raw key_name)
USERNAME="ubuntu"
PRIVATE_KEY=$(terraform output -raw private_key_pem)


# Alte Inventory-Datei löschen
INVENTORY_FILE_OLD="inventory.ini.off"
if [ -f "$INVENTORY_FILE_OLD" ]; then
  echo -e "\n🗑️ Alte Inventory-Datei gefunden. Lösche $INVENTORY_FILE_OLD...\n"
  rm -f "$INVENTORY_FILE_OLD"
fi

# Letzte Inventory-Datei sichern
INVENTORY_FILE="inventory.ini"
if [ -f "$INVENTORY_FILE" ]; then
  mv "$INVENTORY_FILE" "$INVENTORY_FILE.off"
  echo -e "\n📦 Letzte Inventory-Datei wird gesichert. Umbenennen auf $INVENTORY_FILE.off...\n"
fi

# Neue Inventory-Datei erstellen
echo -e "\n📝 Erstelle neue Ansible Inventory-Datei...\n"
cat <<EOF > $INVENTORY_FILE
[jenkins]
$JENKINS_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[jenkins_docker_node]
$JENKINS_DOCKER_NODE_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[app_ec2]
$APP_EC2_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[docker_app_ec2]
$DOCKER_APP_EC2_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo -e "✅ Inventory-Datei wurde erstellt: $INVENTORY_FILE\n"

# Ansible-Konfigurationsdatei erstellen
ANSIBLE_CFG="ansible.cfg"
echo -e "\n📝 Erstelle Ansible Konfigurationsdatei...\n"
cat <<EOF > $ANSIBLE_CFG
[defaults]
inventory = inventory.ini

[ssh_connection]
pipelining = True
EOF

echo -e "✅ Ansible Konfigurationsdatei wurde erstellt: $ANSIBLE_CFG\n"

# Ansible-Testlauf
echo -e "\n🚀 Teste Ansible-Verbindung...\n"

ansible-playbook ../ansible/check_connection.yml

echo -e "\n🎉 Alle Instanzen erreichbar und bereit\n"

echo "🌍 Jenkins SSH & URL: ssh -i $PRIVATE_KEY $USERNAME@$JENKINS_IP & http://$JENKINS_IP:8080"
echo "🌍 Jenkins Docker Node SSH: ssh -i $PRIVATE_KEY $USERNAME@$JENKINS_DOCKER_NODE_IP"
echo "🌍 App EC2 SSH & URL: ssh -i $PRIVATE_KEY $USERNAME@$APP_EC2_IP & http://$APP_EC2_IP"
echo "🌍 Docker App EC2 SSH & URL: ssh -i $PRIVATE_KEY $USERNAME@$DOCKER_APP_EC2_IP & http://$DOCKER_APP_EC2_IP"

echo -e "\n🔑 Public-Key: $KEY_NAME"
echo -e "🔑 Private-Key: $PRIVATE_KEY\n"

while true; do
    read -p "🚀 Soll die Konfiguration der Instanzen gestartet werden? ja oder nein🚀: " answer
    case "${answer,,}" in
        j|ja)
            echo -e "\n💾 Starte install.sh..."
            ./install.sh
            break
            ;;
        n|nein)
            echo -e "\n❌ Kein Problem, die Infrastruktur wurde nicht konfiguriert."
            break
            ;;
        *)
            echo -e "\n❌ Ungültige Antwort. Bitte 'ja' oder 'nein' eingeben."
            ;;
    esac
done
