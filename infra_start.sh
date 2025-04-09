#!/bin/bash

# Terraform Deployment & Ansible Setup Script
# 31.03.2025
# Author: Marcus Bieber



# Nutzen von absoluten Pfaden
# und um Probleme mit relativen Pfaden zu vermeiden
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

set -e  # Beende das Skript bei Fehlern

export TF_VAR_home_path="$HOME"

echo -e "\n🚀 Starte Terraform Deployment...\n"
terraform -chdir=$TERRAFORM_DIR init

if [ -n "$(terraform -chdir=$TERRAFORM_DIR state list)" ]; then
  echo "❌Terraform hat bereits Ressourcen erstellt. Skript wird nicht erneut ausgeführt❌"
  exit 1
fi

terraform -chdir=$TERRAFORM_DIR apply -auto-approve
echo -e "\n🎉 Terraform Deployment abgeschlossen.\n"

# Terraform-Output abrufen und als Array speichern
JENKINS_IPS=($(terraform -chdir=$TERRAFORM_DIR output -json jenkins_instances_ips | jq -r '.[]'))
WEB_IPS=($(terraform -chdir=$TERRAFORM_DIR output -json web_instances_ips | jq -r '.[]'))

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

PUBLIC_KEY=$(terraform -chdir=$TERRAFORM_DIR output -raw key_name)
USERNAME="ubuntu"
PRIVATE_KEY=$(terraform -chdir=$TERRAFORM_DIR output -raw private_key_pem)

# Alte Inventory-Datei löschen
INVENTORY_FILE_OLD="$ANSIBLE_DIR/inventory.ini.old" 
if [ -f "$INVENTORY_FILE_OLD" ]; then
  rm -f "$INVENTORY_FILE_OLD"
  echo -e "\nAlte Inventory-Datei gefunden, $INVENTORY_FILE_OLD wird gelöscht...🗑️"
fi

# Letzte Inventory-Datei sichern
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"
if [ -f "$INVENTORY_FILE" ]; then
  mv "$INVENTORY_FILE" "$INVENTORY_FILE.old"
  echo -e "\nLetzte Inventory-Datei wird gesichert. Umbenennen auf $INVENTORY_FILE.old...📦\n"
fi

# Neue Inventory-Datei erstellen
echo -e "\n📝 Erstelle neue Ansible Inventory-Datei..."
cat <<EOF > $INVENTORY_FILE
[jenkins]
jenkins_master ansible_host=$JENKINS_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[jenkins_docker_node]
jenkins_agent ansible_host=$JENKINS_DOCKER_NODE_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[app_ec2]
app_server_dev ansible_host=$APP_EC2_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[docker_app_ec2]
app_server_prod ansible_host=$DOCKER_APP_EC2_IP ansible_ssh_user=$USERNAME ansible_ssh_private_key_file=$PRIVATE_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo -e "✅ Inventory-Datei wurde erstellt: $INVENTORY_FILE\n"

# Ansible-Konfigurationsdatei erstellen
ANSIBLE_CFG="$ANSIBLE_DIR/ansible.cfg"
echo -e "\n📝 Erstelle Ansible Konfigurationsdatei..."
cat <<EOF > $ANSIBLE_CFG
[defaults]
inventory = inventory.ini

[ssh_connection]
pipelining = True
EOF

echo -e "✅ Ansible Konfigurationsdatei wurde erstellt: $ANSIBLE_CFG\n"

# Ansible-Testlauf
echo -e "\nTeste Ansible-Verbindung...\n"

cd $ANSIBLE_DIR && 
ansible-playbook check_connection.yml &&
cd ..

echo -e "\nVerfügbare Instanzen erreichbar und bereit🎉\n"

echo "🌍 Jenkins SSH & URL: ssh -i $PRIVATE_KEY $USERNAME@$JENKINS_IP & http://$JENKINS_IP:8080"
echo "🌍 Jenkins Docker Node SSH: ssh -i $PRIVATE_KEY $USERNAME@$JENKINS_DOCKER_NODE_IP"
echo "🌍 App EC2 SSH & URL: ssh -i $PRIVATE_KEY $USERNAME@$APP_EC2_IP & http://$APP_EC2_IP"
echo "🌍 Docker App EC2 SSH & URL: ssh -i $PRIVATE_KEY $USERNAME@$DOCKER_APP_EC2_IP & http://$DOCKER_APP_EC2_IP"

echo -e "\n🔑 Public-Key: $PUBLIC_KEY"
echo -e "🔑 Private-Key: $PRIVATE_KEY\n"

while true; do
    read -p "Soll die Konfiguration der Instanzen gestartet werden? ja oder nein: " answer
    case "${answer,,}" in
        j|ja)
            echo -e "\nStarte install.sh...🚀"
            ./install.sh
            break
            ;;
        n|nein)
            echo -e "\nSkript wird beendet, die Infrastruktur wurde nicht konfiguriert.\n"
            break
            ;;
        *)
            echo -e "\n❌Ungültige Antwort. Bitte 'ja' oder 'nein' eingeben❌"
            ;;
    esac
done
