output "jenkins_public_ips" {
  description = "Public IP addresses of Jenkins instances"
  value       = [for vm in azurerm_linux_virtual_machine.jenkins : vm.public_ip_address]
}

output "web_public_ips" {
  description = "Public IP addresses of web instances"
  value       = [for vm in azurerm_linux_virtual_machine.web : vm.public_ip_address]
}

output "private_key_path" {
  value = local_file.private_key.filename  # Pfad zur PEM-Datei
}