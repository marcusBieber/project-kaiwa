output "public_ips" {
  value = concat (aws_instance.jenkins[*].public_ip, aws_instance.web[*].public_ip)
}

output "jenkins_instances_ips" {
  value = aws_instance.jenkins[*].public_ip
}

output "web_instances_ips" {
  value = aws_instance.web[*].public_ip
}

output "private_key_pem" {
    value = local_file.private_key.filename
}

output "key_name" {
  value = aws_key_pair.generated_key.key_name
}