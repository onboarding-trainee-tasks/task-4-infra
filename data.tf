data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_route53_zone" "main" {
  name         = "coinops-d.pp.ua."
  private_zone = false
}

data "aws_acm_certificate" "main" {
  domain      = "coinops-d.pp.ua"
  statuses    = ["ISSUED"]
  most_recent = true
}