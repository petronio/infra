terraform {
  required_providers {
    dns = {
      source = "hashicorp/dns"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

resource "dns_a_record_set" "miyazaki_petroniocoelho_com" {
  addresses = ["176.223.142.63"]
  name      = "miyazaki"
  zone      = "petroniocoelho.com."
}

resource "dns_aaaa_record_set" "miyazaki_petroniocoelho_com" {
  addresses = ["2a02:7b40:b0df:8e3f::1"]
  name      = "miyazaki"
  zone      = "petroniocoelho.com."
}

data "hcloud_server" "ebino_petroniocoelho_com" {
  name = "ebino.petroniocoelho.com"
}

data "hcloud_server" "furano_petroniocoelho_com" {
  name = "furano.petroniocoelho.com"
}

resource "dns_a_record_set" "petroniocoelho_com" {
  addresses = [
    data.hcloud_server.ebino_petroniocoelho_com.ipv4_address,
    data.hcloud_server.furano_petroniocoelho_com.ipv4_address
  ]
  zone = "petroniocoelho.com."
}

resource "dns_aaaa_record_set" "petroniocoelho_com" {
  addresses = [
    data.hcloud_server.ebino_petroniocoelho_com.ipv6_address,
    data.hcloud_server.furano_petroniocoelho_com.ipv6_address
  ]
  zone = "petroniocoelho.com."
}

resource "dns_cname_record" "www_petroniocoelho_com" {
  cname = "petroniocoelho.com."
  name  = "www"
  zone  = "petroniocoelho.com."
}

resource "dns_mx_record_set" "petroniocoelho_com" {
  mx {
    exchange   = "aspmx.l.google.com."
    preference = 1
  }
  mx {
    exchange   = "alt1.aspmx.l.google.com."
    preference = 5
  }
  mx {
    exchange   = "alt2.aspmx.l.google.com."
    preference = 5
  }
  mx {
    exchange   = "aspmx2.googlemail.com."
    preference = 10
  }
  mx {
    exchange   = "aspmx3.googlemail.com."
    preference = 10
  }
  zone = "petroniocoelho.com."
}

resource "dns_txt_record_set" "google__domainkey_petroniocoelho_com" {
  name = "google._domainkey"
  txt = [
    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCltaabBTCTWlTyhxcUj19+y7IvvpGaBVF6Up+OEAn2IJ9v0zhYI9PnI8kkM8YRH/CIRCI+pqf5v5QKgxdijk/vFuh+90C9WyWksuBaG6ZV+9rnWOd75N+MoMZBK7cIUUFUWzdddgVqlFzFh09eS2sFxovWLzaxy8V58BOeFOmltQIDAQAB"
  ]
  zone = "petroniocoelho.com."
}

resource "dns_txt_record_set" "petroniocoelho_com" {
  txt = [
    "v=spf1 include:_spf.google.com -all",
    "keybase-site-verification=o-0noznp6aCRtkF8xqTQZRUEaGsS5_5Q5A_Q-z0xxEw"
  ]
  zone = "petroniocoelho.com."
}
