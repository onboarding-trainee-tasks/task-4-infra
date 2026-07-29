data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

variable "packer_ansible_ami" {
  description = "ID of AMI created by Packer for Ansible Host"
  type        = string
  default     = "ami-0fbd5f35bf4bff7b5"
}

variable "allowed_cidr_blocks" {
  description = "A list of allowed CIDR blocks for the security group"
  type        = list(string)
  default     = ["178.212.0.0/16"]
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