terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

data "cloudflare_zone" "petroniocoelho_com" {
  name = "petroniocoelho.com"
}

resource "cloudflare_record" "acme_challenge_petroniocoelho_com" {
  count   = length(var.petronio_coelho_domains)
  name    = "_acme-challenge.${var.petronio_coelho_domains[count.index] == "" ? "" : "${var.petronio_coelho_domains[count.index]}."}petroniocoelho.com"
  type    = "CNAME"
  value   = "${var.petronio_coelho_domains[count.index] == "" ? "" : "${var.petronio_coelho_domains[count.index]}."}petroniocoelho.com.acme.coelho.dev."
  zone_id = data.cloudflare_zone.petroniocoelho_com.id
}
