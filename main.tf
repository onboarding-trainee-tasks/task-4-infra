module "network" {
  source   = "./modules/network"
  vpc_cidr = "10.10.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  subnets = {
    public_subnet_1 = {
      cidr = "10.10.1.0/24"
      type = "public"
    }
  }
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.network.vpc_id

  security_groups = {
    ansible_sg = {
      name                    = "bastion_sg"
      tcp_ingress_ports       = [22]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = var.allowed_cidr_blocks
      allowed_security_groups = []
    }
    web_sg = {
      name                    = "web_sg"
      tcp_ingress_ports       = [80, 443]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["ansible_sg"]
    }
  }
}

module "ansible_instance" {
  source               = "./modules/instance"
  instance_name        = "ansible"
  instance_type        = "t3.micro"
  volume_size          = 10
  subnet_id            = module.network.public_subnet_ids[0]
  ssh_key_name         = var.ssh_key_name
  security_group_ids   = [module.security_group.sg_ids["ansible_sg"]]
  # ami_id               = var.packer_bastion_ami
  iam_instance_profile = module.iam.iam_instance_profile_name
}