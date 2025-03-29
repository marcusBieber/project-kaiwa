output "jenkins_instance_ip" {
  value = aws_instance.jenkins.public_ip
}

output "web_instances_ips" {
  value = aws_instance.web[*].public_ip
}

output "key_name" {
  value = aws_key_pair.generated_key.key_name
}