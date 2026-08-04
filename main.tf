module "network" {
  source   = "./modules/network"
  vpc_cidr = "10.10.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  subnets = {
    public_subnet_1 = {
      cidr = "10.10.1.0/24"
      type = "public"
    }
    public_subnet_2 = {
      cidr = "10.10.2.0/24"
      type = "public"
    }
  }
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.network.vpc_id

  security_groups = {
    ansible_sg = {
      name                    = "ansible_sg"
      tcp_ingress_ports       = [22]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = var.allowed_cidr_blocks
      allowed_security_groups = []
    }
    alb_sg = {
      name                    = "alb_sg"
      tcp_ingress_ports       = [80, 443]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = ["0.0.0.0/0"]
      allowed_security_groups = []
    }
    web_sg = {
      name                    = "web_sg"
      tcp_ingress_ports       = [80]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["alb_sg"]
    }
    web_ssh_sg = {
      name                    = "web_ssh_sg"
      tcp_ingress_ports       = [22]
      udp_ingress_ports       = []
      allowed_cidr_blocks     = []
      allowed_security_groups = ["ansible_sg"]
    }
  }
}

module "iam" {
  source = "./modules/iam"
}

module "ansible_instance" {
  source = "./modules/instance"

  instance_name = "ansible"
  instance_type = "t3.micro"
  volume_size   = 10

  subnet_id          = module.network.public_subnet_ids[0]
  private_ip         = "10.10.1.100"
  ssh_key_name       = var.ssh_key_name
  security_group_ids = [module.security_group.sg_ids["ansible_sg"]]

  ami_id               = var.packer_ansible_ami
  iam_instance_profile = module.iam.iam_instance_profile_name
  user_data            = "./scripts/ansible_bootstrap.sh"
}

module "web_server_instance" {
  source = "./modules/instance"

  instance_name = "web_server"
  instance_type = "t3.small"
  volume_size   = 10

  subnet_id          = module.network.public_subnet_ids[0]
  private_ip         = "10.10.1.111"
  ssh_key_name       = var.ssh_key_name
  security_group_ids = [module.security_group.sg_ids["web_sg"], module.security_group.sg_ids["web_ssh_sg"]]

  ami_id = data.aws_ami.ubuntu.id
}

module "alb" {
  source            = "./modules/alb"
  security_group_id = [module.security_group.sg_ids["alb_sg"]]
  subnet_ids        = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id
  instance_id       = module.web_server_instance.instance_id
  certificate_arn   = data.aws_acm_certificate.main.arn
}

module "app_dns_record" {
  source = "./modules/dns_record"
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "app.coinops-d.pp.ua"
  type    = "A"

  dns_name     = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
}

module "auth_dns_record" {
  source = "./modules/dns_record"
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "auth.coinops-d.pp.ua"
  type    = "A"

  dns_name     = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
}

module "github_app_dns_record" {
  source = "./modules/dns_record"
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "github-app.coinops-d.pp.ua"
  type    = "A"

  dns_name     = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
}