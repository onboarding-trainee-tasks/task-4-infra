variable "packer_ansible_ami" {
  description = "ID of AMI created by Packer for Ansible Host"
  type        = string
  default     = "ami-0e0f673ee64db1379"
}

variable "packer_web_server_ami" {
  description = "AMI ID created by Packer for Web Server"
  type        = string
  default     = "ami-0a9f0b27ed01a210b"
}

variable "allowed_cidr_blocks" {
  description = "A list of allowed CIDR blocks for the security group"
  type        = list(string)
  default     = ["164.137.0.0/16"]
}

variable "aws_region" {
  description = "Region where resources are deployed"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = "t4-controller"
}