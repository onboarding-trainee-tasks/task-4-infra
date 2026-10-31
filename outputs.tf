output "ssh_command" {
  description = "The SSH command to connect to the bastion host"
  value       = "ssh -i C:\\Onboarding\\.ssh\\t4-controller.pem ubuntu@${module.ansible_instance.public_ip}"
}

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = module.web_server_instance.public_ip
}