#!/bin/bash

# Terraform Deployment Script
# 02.04.2025
# Author: Marcus Bieber

# Nutzen von absoluten Pfaden
# und um Probleme mit relativen Pfaden zu vermeiden
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

set -e  # Beende das Skript bei Fehlern

export TF_VAR_home_path="$HOME"

echo -e "\n💀 Dieses Skript löscht das gesamte Terraform Deployment💀\n"

echo -e "$(terraform -chdir=$TERRAFORM_DIR state list)\n"

while true; do
    read -p "Wirklich fortfahren❓ ja oder nein: " answer
    case "${answer,,}" in
        j|ja)
            echo -e "\n☠️  Deployment wird gelöscht☠️\n"
            terraform -chdir=$TERRAFORM_DIR destroy -auto-approve
            break
            ;;
        n|nein)
            echo -e "\nVorgang abgebrochen. Deployment bleibt bestehen.\n"
            break
            ;;
        *)
            echo -e "\n❌Ungültige Antwort. Bitte 'ja' oder 'nein' eingeben❌"
            ;;
    esac
done
