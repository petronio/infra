# Infra
The code for the infrastructure behind `petroniocoelho.com` and friends. While reusability isn't the intent of this project, it's possible to reuse most of it with some effort.

## Services Managed

### **Authoritative DNS**
- [x] Automated DNSSEC
- [x] Master with dual read slave configuration
- [x] TSIG slave authentication

### **Base servers**
- [x] Automated updating enabled
- [x] Automated Let's Encrypt
- [x] Key-only and no root SSH
- [x] Wireguard VPN (bi-directional)

### **Resilio Sync**
A service I have used for a long time, great for backing up mobile devices.

- [x] Mounted to a Hetzner storage box via encrypted CIFS

## Planned Services & Features

- [ ] Monitoring
- [ ] Nextcloud instance
- [ ] SMTP & IMAP

## FAQ

### **I would like to reuse this, any advice?**
The external service providers currently used are:

* AWS
* Hetzner

Of those, AWS is easily replaced or removed, as it's currently only being used for storing and locking of the terraform state. Hetzner would require a much larger overhaul, particularly within Terraform.

In addition to accounts for the above, you'll need to order a Hetzner storage box (they don't currently support Terraform for that service). If using AWS for storing terraform state, the `backend` section should be initially omitted, as the bucket and dynamodb table need to be created first. 

The `pass` utility is used extensively to store secrets outside of this repo and is called by both Terraform and Ansible. Its current structure is as follows:

```
├── api_keys
│   └── hetzner
├── dns
│   ├── _acme-challenge.ebino.petroniocoelho.com_tsig
│   ├── _acme-challenge.furano.petroniocoelho.com_tsig
│   ├── _acme-challenge.toba.petroniocoelho.com_tsig
│   ├── ebino.petroniocoelho.com_tsig
│   ├── furano.petroniocoelho.com_tsig
│   ├── _workstation.osaka.petroniocoelho.com_tsig_algorithm
│   ├── _workstation.osaka.petroniocoelho.com_tsig
│   ├── _workstation.osaka.petroniocoelho.com_tsig_name
│   └── _workstation.osaka.petroniocoelho.com_tsig_secret
├── storage_box
│   ├── resilio_config
│   ├── resilio_password
│   ├── resilio_username
│   └── server
└── wireguard
    ├── osaka
    └── shimane
```

AWS authentication is handled with an `awscli` profile.

You should do a search & replace for `petroniocoelho.com`, `petroniocoelho_com`, and any server names you'd like to change. Review the variables in `ansible/group_vars/` as well.

Although there is automation for DNS, since we're hosting the nameservers here as well, initial setup is necessary:
* Comment out the `dns` provider and related resources in Terraform, then `terraform apply`
* Once the machines are created, update `terraform/variables.tf` and `ansible/group_vars/dns.yml`
* Update your local `/etc/hosts` to temporarily add the hostnames for the DNS master and slaves, as `ansible/hosts` uses them
* Run `ansible_playbook base.yml dns_master.yml dns_slave.yml`
* Un-comment the `dns` provider and related resources, then `terraform apply`
* Update `NS`, `DS`, and glue records (A and AAAA records for your dns slaves) at your registrar
  * `DS` records can be obtained from running `dnssec-dsfromkey` on the dns master against the `.key` files located in `/var/named/`

TSIG keys can be generated with `tsig-keygen FQDN`, remembering that the FQDN should include the ending root (`.`). FQDNs for ssl bot keys must be prefixed with `_acme-challenge.` and for workstation keys `_workstation.` .
