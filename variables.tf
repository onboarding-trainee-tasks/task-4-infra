variable "packer_ansible_ami" {
  description = "ID of AMI created by Packer for Ansible Host"
  type        = string
  default     = "ami-0beb37b560a251134"
}

variable "allowed_cidr_blocks" {
  description = "A list of allowed CIDR blocks for the security group"
  type        = list(string)
  default     = ["178.212.0.0/16", "195.160.0.0/16"]
}

variable "aws_region" {
  description = "Region where resources are deployed"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = "terraform-ssh-key"
}