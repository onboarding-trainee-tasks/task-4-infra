output "ssh_command" {
  description = "The SSH command to connect to the bastion host"
  value       = "ssh -i ~/.ssh/t4-controller ubuntu@${module.ansible_instance.public_ip}"
}

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = module.web_server_instance.public_ip
}

output "ansible_controller_public_ip" {
  description = "Current public IP of Ansible Controller"
  value       = module.ansible_instance.public_ip
}