variable "domain_name" {
  type = string
  default = "<<<DOMAINNAME>>>-<<<DOMAINSUFFIX>>>"
}

variable "domain_fqdn" {
  type = string
  default = "<<<DOMAINNAME>>>.<<<DOMAINSUFFIX>>>"
}

data "http" "current_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "namecheap_domain_records" "<<<DOMAINNAME>>>" {
  domain = "${var.domain_fqdn}"
  mode = "MERGE"
  email_type = "MX"

  record {
    hostname = "<<<EC2NAME>>>"
    type = "A"
    address = module.<<<EC2NAME>>>[0].public_ip
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "<<<EC2NAME>>>-vpc"
  cidr = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  tags = { 
    Terraform = "true"
    project   = "<<<EC2NAME>>>"
  }
}

module "ami-search" {
  source = "./modules/ami-search"
  os     = var.ec2_img
}

module "ansible_key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "ansible_<<<EC2NAME>>>"
  public_key = file("${var.ssh_public_key_location}")
}

module "<<<EC2NAME>>>_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "<<<EC2NAME>>>-sg"
  description = "Security group <<<EC2NAME>>> instance"
  vpc_id      = module.vpc.vpc_id
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow All Outbound"
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 51820
      to_port     = 51820
      protocol    = "udp"
      description = "Wireguard"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_security_group_rule" "ssh_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.current_ip.body)}/32"]
  security_group_id = module.<<<EC2NAME>>>_sg.security_group_id
  description       = "SSH"
}

resource "aws_security_group_rule" "dns_access" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["${chomp(data.http.current_ip.body)}/32"]
  security_group_id = module.<<<EC2NAME>>>_sg.security_group_id
  description       = "DNS"
}

resource "aws_security_group_rule" "http_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.current_ip.body)}/32"]
  security_group_id = module.<<<EC2NAME>>>_sg.security_group_id
  description       = "HTTP"
}

resource "aws_security_group_rule" "https_access" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.current_ip.body)}/32"]
  security_group_id = module.<<<EC2NAME>>>_sg.security_group_id
  description       = "HTTPS"
}


module "<<<EC2NAME>>>" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  count = 1
  name = "<<<EC2NAME>>>-vm-1"
  ami = module.ami-search.ami_id
  associate_public_ip_address = true
  instance_type = "<<<EC2SIZE>>>"
  key_name = "ansible_<<<EC2NAME>>>"
  monitoring = true
  vpc_security_group_ids = [module.<<<EC2NAME>>>_sg.security_group_id]
  subnet_id = tolist(module.vpc.public_subnets)[count.index]
  user_data = data.template_cloudinit_config.config.rendered
  root_block_device = [{
    volume_type = "gp2"
    volume_size = 50
  }]
  tags = {
    Terraform = "true"
    project = "<<<EC2NAME>>>"
  }
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content = <<-EOF
      #! /bin/bash
      export PATH=$PATH:/usr/bin
      sudo apt-get update
      sudo adduser --disabled-password --gecos '' ansible
      sudo mkdir -p /home/ansible/.ssh
      sudo touch /home/ansible/.ssh/authorized_keys
      sudo echo '${file("${var.ssh_public_key_location}")}' > authorized_keys
      sudo mv authorized_keys /home/ansible/.ssh
      sudo chown -R ansible:ansible /home/ansible/.ssh
      sudo chmod 700 /home/ansible/.ssh
      sudo chmod 600 /home/ansible/.ssh/authorized_keys
      sudo usermod -aG sudo ansible
      sudo echo 'ansible ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers
    EOF
  }
}
