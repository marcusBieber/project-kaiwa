#!/bin/bash

# Terraform Deployment & Ansible Setup Script
# 31.03.2025
# Author: Marcus Bieber

set -e  # Beende das Skript bei Fehlern

echo "🚀 Starte Terraform Deployment..."
terraform init
terraform apply -auto-approve
echo "🎉 Deployment abgeschlossen."

# Terraform-Output abrufen und als Array speichern
echo "💻 Abrufen der IP-Adressen..."
PUBLIC_IPS=($(terraform output -json public_ips | jq -r '.[]'))

# Prüfen, ob 4 IPs vorhanden sind
if [ ${#PUBLIC_IPS[@]} -lt 4 ]; then
  echo "❌ Fehler: Weniger als 4 IP-Adressen im Terraform-Output gefunden!"
  exit 1
fi

# IP-Adressen den Hostgruppen zuweisen
JENKINS_IP=${PUBLIC_IPS[0]}
JENKINS_DOCKER_NODE_IP=${PUBLIC_IPS[1]}
APP_EC2_IP=${PUBLIC_IPS[2]}
DOCKER_APP_EC2_IP=${PUBLIC_IPS[3]}

KEY_NAME=$(terraform output -raw key_name)
USERNAME="ubuntu"
PRIVATE_KEY_PATH=$(terraform output -raw private_key_pem)

echo "🔑 Schlüsselname: $KEY_NAME"
echo "🌍 Jenkins: $JENKINS_IP"
echo "🌍 Jenkins Docker Node: $JENKINS_DOCKER_NODE_IP"
echo "🌍 App EC2: $APP_EC2_IP"
echo "🌍 Docker App EC2: $DOCKER_APP_EC2_IP"

# Alte Inventory-Datei löschen
INVENTORY_FILE_OLD="inventory.ini.off"
if [ -f "$INVENTORY_FILE_OLD" ]; then
  echo "🗑️ Alte Inventory-Datei gefunden. Lösche..."
  rm -f inventory.ini
fi

# Letzte Inventory-Datei sichern
INVENTORY_FILE="inventory.ini"
if [ -f "$INVENTORY_FILE" ]; then
  echo "📦 Alte Inventory-Datei gefunden. Umbenennen auf $INVENTORY_FILE.off..."
  mv "$INVENTORY_FILE" "$INVENTORY_FILE.off"
fi

# Neue Inventory-Datei erstellen
echo "📝 Erstelle neue Ansible Inventory-Datei..."
cat <<EOF > $INVENTORY_FILE
[jenkins]
$JENKINS_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY_PATH ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[jenkins_docker_node]
$JENKINS_DOCKER_NODE_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY_PATH ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[app_ec2]
$APP_EC2_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY_PATH ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[docker_app_ec2]
$DOCKER_APP_EC2_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY_PATH ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "✅ Inventory-Datei wurde erstellt: $INVENTORY_FILE"

# Ansible-Konfigurationsdatei erstellen
ANSIBLE_CFG="ansible.cfg"
echo "📝 Erstelle Ansible Konfigurationsdatei..."
cat <<EOF > $ANSIBLE_CFG
[defaults]
inventory = inventory.ini

[ssh_connection]
pipelining = True
EOF

echo "✅ Ansible Konfigurationsdatei wurde erstellt: $ANSIBLE_CFG"

# Ansible-Testlauf
echo "🚀 Teste Ansible-Verbindung..."

ansible-playbook ../ansible/check_connection.yml

echo "🎉 Alle Instanzen erreichbar und bereit"

while true; do
    read -p "🚀 Soll die Konfiguration der Instanzen gestartet werden? ja oder nein🚀: " answer
    case "${answer,,}" in
        j|ja)
            echo "💾 Starte install.sh..."
            ./install.sh
            break
            ;;
        n|nein)
            echo "❌ Kein Problem, die Infrastruktur wurde nicht konfiguriert."
            break
            ;;
        *)
            echo "❌ Ungültige Antwort. Bitte 'ja' oder 'nein' eingeben."
            ;;
    esac
done
