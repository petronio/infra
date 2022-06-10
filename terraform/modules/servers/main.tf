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

data "hcloud_ssh_key" "petronio_ed25519" {
  name = "Petronio Coelho (ed25519)"
}

#
# hcloud networks
#

resource "hcloud_network" "infra" {
  name              = "infra"
  delete_protection = true
  ip_range          = var.infra_subnet
}

resource "hcloud_network_subnet" "infra_1" {
  type         = "cloud"
  network_id   = hcloud_network.infra.id
  network_zone = "eu-central"
  ip_range     = cidrsubnet(hcloud_network.infra.ip_range, 8, 0)
}

#
# hcloud firewall rules
#

resource "hcloud_firewall" "dns_in" {
  name = "dns_in"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "53"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "53"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "ssh_in" {
  name = "ssh_in"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "wireguard_in" {
  name = "wireguard_in"
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "51820"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

#
# hcloud placement groups
#

resource "hcloud_placement_group" "fsn1" {
  name = "fsn1"
  type = "spread"
}

resource "hcloud_placement_group" "nbg1" {
  name = "nbg1"
  type = "spread"
}

#
# ebino.petroniocoelho.com
#

resource "hcloud_server" "ebino" {
  name              = "ebino.petroniocoelho.com"
  delete_protection = true
  image             = "centos-stream-9"
  firewall_ids = [
    hcloud_firewall.dns_in.id,
    hcloud_firewall.ssh_in.id
  ]
  location           = "fsn1"
  placement_group_id = hcloud_placement_group.fsn1.id
  rebuild_protection = true
  server_type        = "cpx11"
  ssh_keys = [
    data.hcloud_ssh_key.petronio_ed25519.id
  ]

  network {
    ip         = cidrhost(hcloud_network_subnet.infra_1.ip_range, 2)
    network_id = hcloud_network_subnet.infra_1.network_id
  }
}

resource "dns_a_record_set" "ebino_petroniocoelho_com" {
  addresses = [hcloud_server.ebino.ipv4_address]
  name      = "ebino"
  zone      = "petroniocoelho.com."
}

resource "dns_aaaa_record_set" "ebino_petroniocoelho_com" {
  addresses = [hcloud_server.ebino.ipv6_address]
  name      = "ebino"
  zone      = "petroniocoelho.com."
}

locals {
  ebino_network_list = tolist(hcloud_server.ebino.network)
}

resource "dns_a_record_set" "internal_ebino_petroniocoelho_com" {
  addresses = [local.ebino_network_list[index(local.ebino_network_list.*.network_id, tonumber(hcloud_network_subnet.infra_1.network_id))].ip]
  name      = "internal.ebino"
  zone      = "petroniocoelho.com."
}

resource "hcloud_rdns" "ebino_ipv4" {
  dns_ptr    = "ebino.petroniocoelho.com"
  ip_address = hcloud_server.ebino.ipv4_address
  server_id  = hcloud_server.ebino.id
}

resource "hcloud_rdns" "ebino_ipv6" {
  dns_ptr    = "ebino.petroniocoelho.com"
  ip_address = hcloud_server.ebino.ipv6_address
  server_id  = hcloud_server.ebino.id
}

#
# furano.petroniocoelho.com
#

resource "hcloud_server" "furano" {
  name              = "furano.petroniocoelho.com"
  delete_protection = true
  image             = "centos-stream-9"
  firewall_ids = [
    hcloud_firewall.dns_in.id,
    hcloud_firewall.ssh_in.id
  ]
  location           = "nbg1"
  placement_group_id = hcloud_placement_group.nbg1.id
  rebuild_protection = true
  server_type        = "cpx11"
  ssh_keys = [
    data.hcloud_ssh_key.petronio_ed25519.id
  ]

  network {
    ip         = cidrhost(hcloud_network_subnet.infra_1.ip_range, 3)
    network_id = hcloud_network_subnet.infra_1.network_id
  }
}

resource "dns_a_record_set" "furano_petroniocoelho_com" {
  addresses = [hcloud_server.furano.ipv4_address]
  name      = "furano"
  zone      = "petroniocoelho.com."
}

resource "dns_aaaa_record_set" "furano_petroniocoelho_com" {
  addresses = [hcloud_server.furano.ipv6_address]
  name      = "furano"
  zone      = "petroniocoelho.com."
}

locals {
  furano_network_list = tolist(hcloud_server.furano.network)
}

resource "dns_a_record_set" "internal_furano_petroniocoelho_com" {
  addresses = [local.furano_network_list[index(local.furano_network_list.*.network_id, tonumber(hcloud_network_subnet.infra_1.network_id))].ip]
  name      = "internal.furano"
  zone      = "petroniocoelho.com."
}

resource "hcloud_rdns" "furano_ipv4" {
  dns_ptr    = "furano.petroniocoelho.com"
  ip_address = hcloud_server.furano.ipv4_address
  server_id  = hcloud_server.furano.id
}

resource "hcloud_rdns" "furano_ipv6" {
  dns_ptr    = "furano.petroniocoelho.com"
  ip_address = hcloud_server.furano.ipv6_address
  server_id  = hcloud_server.furano.id
}

#
# toba.petroniocoelho.com
#

resource "hcloud_server" "toba" {
  name              = "toba.petroniocoelho.com"
  delete_protection = true
  image             = "centos-stream-9"
  firewall_ids = [
    hcloud_firewall.ssh_in.id,
    hcloud_firewall.wireguard_in.id
  ]
  location           = "fsn1"
  placement_group_id = hcloud_placement_group.fsn1.id
  rebuild_protection = true
  server_type        = "cpx21"
  ssh_keys = [
    data.hcloud_ssh_key.petronio_ed25519.id
  ]

  network {
    ip         = cidrhost(hcloud_network_subnet.infra_1.ip_range, 4)
    network_id = hcloud_network_subnet.infra_1.network_id
  }
}

resource "dns_a_record_set" "toba_petroniocoelho_com" {
  addresses = [hcloud_server.toba.ipv4_address]
  name      = "toba"
  zone      = "petroniocoelho.com."
}

resource "dns_aaaa_record_set" "toba_petroniocoelho_com" {
  addresses = [hcloud_server.toba.ipv6_address]
  name      = "toba"
  zone      = "petroniocoelho.com."
}

locals {
  toba_network_list = tolist(hcloud_server.toba.network)
}

resource "dns_a_record_set" "internal_toba_petroniocoelho_com" {
  addresses = [local.toba_network_list[index(local.toba_network_list.*.network_id, tonumber(hcloud_network_subnet.infra_1.network_id))].ip]
  name      = "internal.toba"
  zone      = "petroniocoelho.com."
}

resource "hcloud_rdns" "toba_ipv4" {
  dns_ptr    = "toba.petroniocoelho.com"
  ip_address = hcloud_server.toba.ipv4_address
  server_id  = hcloud_server.toba.id
}

resource "hcloud_rdns" "toba_ipv6" {
  dns_ptr    = "toba.petroniocoelho.com"
  ip_address = hcloud_server.toba.ipv6_address
  server_id  = hcloud_server.toba.id
}

#
# Wireguard route to toba.petroniocoelho.com
#

resource "hcloud_network_route" "wireguard" {
  destination = cidrsubnet(hcloud_network.infra.ip_range, 8, 200)
  gateway     = local.toba_network_list[index(local.toba_network_list.*.network_id, tonumber(hcloud_network_subnet.infra_1.network_id))].ip
  network_id  = hcloud_network.infra.id
}
