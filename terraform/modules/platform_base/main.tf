terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

resource "aws_s3_account_public_access_block" "root" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "hcloud_ssh_key" "petronio_ed25519" {
  name       = "Petronio Coelho (ed25519)"
  public_key = file("~/.ssh/id_ed25519.pub")
}
