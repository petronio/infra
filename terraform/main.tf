terraform {
  backend "s3" {
    bucket         = "petronio-terraform"
    dynamodb_table = "terraform"
    key            = "infra/root.tfstate"
    profile        = "petronio"
    region         = "eu-north-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    dns = {
      source = "hashicorp/dns"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    pass = {
      source = "camptocamp/pass"
    }
  }
}

provider "aws" {
  profile = "petronio"
  region  = "eu-north-1"
}

data "pass_password" "dns_workstation_tsig_algorithm" {
  path = "dns/_workstation.${var.dns_workstation_fqdn}_tsig_algorithm"
}

data "pass_password" "dns_workstation_tsig_name" {
  path = "dns/_workstation.${var.dns_workstation_fqdn}_tsig_name"
}

data "pass_password" "dns_workstation_tsig_secret" {
  path = "dns/_workstation.${var.dns_workstation_fqdn}_tsig_secret"
}

provider "dns" {
  update {
    key_algorithm = data.pass_password.dns_workstation_tsig_algorithm.password
    key_name      = data.pass_password.dns_workstation_tsig_name.password
    key_secret    = data.pass_password.dns_workstation_tsig_secret.password
    server        = var.dns_master_internal_ip
  }
}

data "pass_password" "api_keys_hetzner" {
  path = "api_keys/hetzner"
}

provider "hcloud" {
  token = data.pass_password.api_keys_hetzner.password
}

module "platform_base" {
  source = "./modules/platform_base"
}

module "terraform_support" {
  source = "./modules/terraform_support"
}

module "servers" {
  source = "./modules/servers"
}

module "misc_dns" {
  source = "./modules/misc_dns"
}
