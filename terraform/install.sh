echo "Konfiguration der Instanzen wird gestartet...🚀"

echo "logs-Verzeichnis wird ertellt falls nicht vorhanden...💾"
mkdir -p ../ansible/logs/
echo "logs-Verzeichnis wurde erstellt...✅"

echo " \
jenkins.yml...🚀 \
jenkins_docker_node.yml...🚀 \
app_ec2.yml...🚀 \
docker_app_ec2.yml...🚀 \
...wurden gestartet...🚀"
ansible-playbook ../ansible/jenkins.yml > ../ansible/logs/jenkins.log 2>&1 &
ansible-playbook ../ansible/jenkins_docker_node.yml > ../ansible/logs/jenkins_docker_node.log 2>&1 &
ansible-playbook ../ansible/app_ec2.yml > ../ansible/logs/app_ec2.log 2>&1 &
ansible-playbook ../ansible/docker_app_ec2.yml > ../ansible/logs/docker_app_ec2.log 2>&1 &
wait
echo "Alle Playbooks wurden ausgeführt, Logs sind in ../ansible/logs...💾"
