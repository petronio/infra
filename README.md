# Infra
The code for the infrastructure behind `petroniocoelho.com` and friends. While reusability isn't the intent of this project, it's possible to reuse most of it pretty easily.

## Services Managed

### **Authoritative DNS**
Running secondary/development domains. Primary domain is still on Cloudflare for reliability purposes.

- [x] Automated DNSSEC
- [x] Master with dual read slave configuration
- [x] TSIG slave authentication

### **Base servers**
- [x] Automated updating enabled
- [x] Key-only and no root SSH

### **Resilio Sync**
A service I have used for a long time, great for backing up mobile devices.

- [x] Mounted to a Hetzner storage box via encrypted CIFS

## Planned Services & Features

- [ ] Monitoring
- [ ] Nextcloud instance
- [ ] SMTP & IMAP
- [ ] Wireguard VPN for services that don't need to be publicly exposed
- [ ] Yubikey/U2F requirement for sudo

## FAQ

### **I would like to reuse this, any advice?**
The external service providers currently used are:

* AWS
* Cloudflare
* Hetzner

Of those, AWS is easily replaced or removed, as it's currently only being used for storing and locking of the terraform state. Cloudflare and Hetzner would require a much larger overhaul, particularly within Terraform.

In addition to accounts for the above, you'll need to manually add your primary domain to Cloudflare and order the Hetzner storage box (they don't currently support Terraform for that service). If using AWS for storing terraform state, the `backend` section should be initially omitted, as the bucket and dynamodb table need to be created first. You'll also need to import the Cloudflare domain into the Terraform state at `platform_base.cloudflare_zone.DOMAIN` .

The `pass` utility is used extensively to store secrets outside of this repo and is called by both Terraform and Ansible. Its current structure is as follows:

```
├── api_keys
│   ├── cloudflare
│   └── hetzner
├── dns
│   ├── ebino.petroniocoelho.com_tsig
│   └── furano.petroniocoelho.com_tsig
└── storage_box
    ├── resilio_config
    ├── resilio_password
    ├── resilio_username
    └── server
```

AWS authentication is handled with an `awscli` profile.

If you intend to use the `dns_master` role, keep in mind that aside from pointing the nameservers to your `dns_slave` server at your registrar, you'll need to generate a DS record from the automatically generated keys with `dnssec-dsfromkey` and add it to your registrar for DNSSEC to validate. The keys are located at `/var/named/` on the master and end with `.key`.

With the exception of the above, you should just do a search & replace for `petroniocoelho.com`, `petroniocoelho_com`, and any server names you'd like to change. No need to worry about IP addresses, nothing is hard coded with the exception of the Hetzner network & subnet (which are also easy to change). Disable any of the ansible playbooks that you don't want to use from `all.yml` and you should be good to go.
