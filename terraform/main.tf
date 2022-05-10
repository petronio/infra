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
    cloudflare = {
      source = "cloudflare/cloudflare"
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

data "pass_password" "api_keys_cloudflare" {
  path = "api_keys/cloudflare"
}

provider "cloudflare" {
  api_token = data.pass_password.api_keys_cloudflare.password
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
